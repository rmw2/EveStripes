function avgTrace = averageTraces(genotype)
%average traces generated by extractTraces together to form a consensus
%TODO - Align stripes before averaging?

%Concatenate all traces
allTraces = [genotype.standardTraces];

%Bin concatenated traces as if it were a single embryo
%Bin traces to create a single 60 x 100 x 4 array
avgTrace = NaN(60,length(genotype(1).CP.APbinID)-1,3);
[~,~, bin] = histcounts(nanmean(allTraces(:,:,4)),genotype(1).CP.APbinID);
%Count up the number of bins represented in each data set
binFreq = zeros(1,100);
for i = 1:length(genotype)
    binFreq = binFreq + any(genotype(i).binTraces(:,:,1)~=0);
end

for t = 1:60
    for x = 1:100
        %Average Total Fluorescence in bin
        avgTrace(t,x,1) = sum(allTraces(t,bin==x,1))/binFreq(x);
        %Mean nonzero fluorescence in bin
        avgTrace(t,x,2) = nanmean(allTraces(t,bin==x,1));
        %Total mRNA in bin at point t
        avgTrace(t,x,3) = sum(allTraces(t,bin==x,5))/binFreq(x);
    end
end