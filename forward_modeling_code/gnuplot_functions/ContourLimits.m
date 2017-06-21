function [f_FreqData,CumFreq_CI] = ContourLimits(NBins,BinnedData,NPoints)
%CONTOURLIMITS In the binned data find the maximum frequency, the frequencies
% above which at least 50, 75 and 95% of data occurs, the cumulative frequency for all
% bins with 5 or more points and the cumulative frequencies for the contour
% intervals.  5 contour intervals are assumed.
%
% f_FreqData(1) = MaxFreq   - Max observed frequency in a bin.
% f_FreqData(2) = Freq95    - Freq where cumulative frequency >= 95%.
% f_FreqData(3) = FreqMin5P - Cumulative freq for all bins with 5 or more points per bin.
% f_FreqData(4) = Freq75    - Freq where cumulative frequency >= 50%.
% f_FreqData(5) = Freq50    - Freq where cumulative frequency >= 75%.
%
% CumFreq_CI(i,1) = The cumulative frequency at the contour i.
% CumFreq_CI(i,2) = The frequency at the contour i.
%
% Doug Rickman Jan 28, 2014

% Preallocate array sizes.
Contour(5)      = 0;
CumFreq_CI(5,2) = 0;

SortedBins = sort(BinnedData(:),'descend'); % Convert to column matrix in sorted order.
MaxFreq = SortedBins(1);                    % The maximum observed frequency in a bin.

% Create a table of accumulated frequencies in sorted order.
SumSortedBins = SortedBins;
for i = 2:(NBins)
    SumSortedBins(i) = SumSortedBins(i-1) + SortedBins(i);
end

% Find the bin, "i", and its frequency, "Freq95", where the accumulation is >=95% of the data.
i = find(SumSortedBins >= 0.95,1, 'first');
Freq95          = SortedBins(i);
CumFreq_CI(1,1) = SumSortedBins(i);
Contour(1)      = Freq95;
CumFreq_CI(1,2) = Contour(1);

% Find the bin, "i", and its frequency, "Freq50", where the accumulation is >=75% of the data.
i = find(SumSortedBins >= 0.75,1, 'first');
Freq75        = SortedBins(i);

% Find the bin, "i", and its frequency, "Freq50", where the accumulation is >=50% of the data.
i = find(SumSortedBins >= 0.5,1, 'first');
Freq50        = SortedBins(i);

test = 5/NPoints;                       % The frequency for a bin with 5 points.
j = find(SortedBins < test,1, 'first'); % Bin number of the 1st bin that has less than 5 points in it.
                                        % Bin j-1 is the last bin with 5 points in it.
% FreqMin5 = SortedBins(j-1);           % Frequency at j-1.  Not useful except for checking code.
FreqMin5P = SumSortedBins(j-1);         % Cumulative frequency for all bins with at least 5 points.  
                                        % Note' this is not terribly useful if enough slices are made.

CI     = (MaxFreq-Freq95)/5;            % There will be 5 contour intervals going from Freq95 to MaxFreq.
for i = 2:5
    Contour(i) = Contour(i-1)+CI;
    j = find(SortedBins < Contour(i),1, 'first');
    CumFreq_CI(i,1) = SumSortedBins(j);
    CumFreq_CI(i,2) = Contour(i);
end

f_FreqData = [MaxFreq,Freq95,FreqMin5P,Freq75,Freq50];

% Checkout code:
% The variable to see in the workspace are SortedBins,SumSortedBins
% disp(['Max frequency = ',num2str(MaxFreq)]);
% disp(['95% at bin = ',num2str(i),'  Value of bin(i) = ',num2str(Freq95)]);
% disp(['Last bin with more than 5 points = ',num2str(j-1),'  Cumulative frequency at that point = ',num2str(FreqMin5P)]);
% 
% disp(Contour);
% for i = 1:5
%     disp(num2str(CumFreq_CI(i)));
% end

end
