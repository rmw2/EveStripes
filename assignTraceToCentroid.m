function whichCluster = ...
    assignTraceToCentroid(fluoTrace, centroids, varargin)
%**************************************************************************
% Given a set of time-trace cluster centroids, (e.g. generated by
% clusterTraces.m), assign a new set of traces to those pre-existing
% centroids. 
%
% Dependencies: none
% RW 9/2015
%**************************************************************************

nTraces = size(fluoTrace,2);

% Distance function
if nargin < 3
    dFun = @(x,y) norm(x-y);
else
    dFun = varargin{1};
end

% Number of different clustering attempts (different k's)
nK = length(centroids);

% Return cell with assignements for each k
whichCluster = cell(1,nK);
for k = 1:nK
    nClusters = size(centroids{k},1);
    
    whichCluster{k} = NaN(1,nTraces);
    
    %Find the nearest centroid to each trace
    for i = 1:nTraces
        %Check distance to each centroid
        d = NaN(1,nClusters);
        for j = 1:nClusters
            d(j) = dFun(fluoTrace(:,i,1),centroids{k}(j,:)');
        end
        [~,whichCluster{k}(i)] = min(d);
    end
end