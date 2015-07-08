%Sort CompiledParticles structures into seven identical structures that
%each represent a single eve stripe.  These can be fed into any
%post-processing code as if it were a true CompiledParticles structure
%
%

%The arg cp is a compiled particles stucture
function [cpByStripe] = sortByStripe(cp)
DEFAULT_CENTROIDS = [0.3 0.38 0.46 0.525 0.59 0.67 0.76]';
nParticles = length(cp.CompiledParticles);
%Each entry in the cell will be a CompiledParsticles-style structure for the
%corresponding eve stripe
cpByStripe = cell(1,7);

%Filter out only nc14
firstFrame = cp.nc14;
frameOfnc14 = firstFrame:length(cp.ElapsedTime);

binSize = cp.APbinID(1);

%Determine which stripes are present in the viewing window
%TODO - make these frames determined dynamically
earlyRange = 1:45;
clusterRange = 46:85;  %use kmeans in this range
lateRange = 86:length(cp.ElapsedTime);


%Maybe make this bit a separate function?
potentialCentroids = cell(1, length(clusterRange));
foundStripes = NaN(length(clusterRange),1);
left = NaN(length(clusterRange),1);
APpos = cell(1,length(clusterRange));
%NOTE: APpos is indexed from 1:length(clusterRange) but the values of
%clusterRange do not begin at 1; t corresponds to frame, T to index
T = 0;
for t = clusterRange
    %Use capital T for indexing 
    T = T+1;
    APpos{T} = getParticlesInFrame(cp.CompiledParticles, frameOfnc14(t));
    
    %Make histogram of frame, smooth, count peaks as proxy for stripes
    posCounts = histcounts(APpos{T}, cp.APbinID);
    w = 3; %moving window size
    smoothCounts = conv(posCounts, ones(1,w)/w, 'same'); %filter
    [~,potentialCentroids{T}] = findpeaks(smoothCounts);
    potentialCentroids{T} = potentialCentroids{T}*binSize - binSize/2;
    foundStripes(t) = length(potentialCentroids{T});
    
    %Compare found centroids to default centroids
    [d, left(t)] = min(abs(potentialCentroids{T}(1)-DEFAULT_CENTROIDS));
end
nStripes = mode(foundStripes);
firstStripe = mode(left);

%First use AllTracesVector to perform clustering on particles alone
%THOUGHT - Cluster in the middle of nc14, only with particles that are
%active at that time, then do assignment based on mean AP positions
%i.e. each particle gets assigned to only one cp structure
centroids = NaN(length(frameOfnc14), nStripes);
T = 0;
for t = clusterRange
    %Captial T for indexing w/i clusterRange
    T = T+1;
    %Do clustering in the mid-nc14 period while stripes are well-defined
    [~, centroids(t,:)] = kmeans(APpos{T}', nStripes);
    centroids(t,:) = sort(centroids(t,:));
end
%Set the centroids for the edges
earlyCentroids = mean(centroids(clusterRange(1:3),:));
centroids(earlyRange,:) = repmat(earlyCentroids,length(earlyRange),1);

lateCentroids = mean(centroids(clusterRange(end-2:end),:));
centroids(lateRange,:) = repmat(lateCentroids,length(lateRange),1);

%TODO- Curate the centroids here



%Centroids will be a vector with a value at each time point, particles will
%be assigned to stripes based on the centroid they are closest to in the
%first frame in which they appear
whichStripe = NaN(1,nParticles);
for i = 1:nParticles
    %Figure out initial frame and position of the particle
    frame = cp.CompiledParticles(i).FirstFrame;
    pos = cp.CompiledParticles(i).APpos(1);
    
    [cp.CompiledParticles(i).DtoCentroid, whichStripe(i)] = ...
        min(abs(centroids(frame,:) - pos));
end

%TODO - assign ellipses w/o particles as well 

%Shift over if any stripes are missing
whichStripe = whichStripe + firstStripe - 1;

%Assign elements of CompiledParticles based on clustering to the cell
for s = 1:nStripes
    cpByStripe{s} = cp.CompiledParticles(whichStripe==s);
end