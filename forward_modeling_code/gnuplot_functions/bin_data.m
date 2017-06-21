function [binnedNormdCounts,freqData,cumFreq_CI,sumBinnedRawCounts] = ...
    bin_data(dataMat, binInterval)
% BIN_DATA Bin AR-HF or C-S data.
% 
% [binnedNormdCounts,freqData,cumFreq_CI,sumBinnedRawCounts] =  ...
% bin_data(dataMat,binInterval) Bins the data contained in dataMat. dataMat
% is a Nx2 matrix. If AR-HF, column 1 is aspect ratio, column 2 is Heywood
% factor. If C-S, column 1 is convexity, column 2 is solidity.
% 
% off2pds uses binInterval = 0.01.
% 
% Updated 5 September 2014.

xBins = 0:binInterval:1;
yBins = 0:binInterval:1;
num_xBins = numel(xBins);
num_yBins = numel(yBins);

% Data binned according to the edges x and y.
binnedRawCounts         = hist3(dataMat, 'Edges', {xBins yBins});
sumBinnedRawCounts      = sum(sum(binnedRawCounts));
binnedNormdCounts       = binnedRawCounts./sumBinnedRawCounts;
[freqData, cumFreq_CI]  = ContourLimits(num_xBins*num_yBins, ...
                            binnedNormdCounts, sumBinnedRawCounts);