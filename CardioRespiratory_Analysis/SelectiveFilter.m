function [Xs] = SelectiveFilter(X,FMAXi,Fs)
%SELECTIVEFILTER Implements the Selective Filter for the Asynch statistic.
%	[Xs] = SelectiveFilter(X,FMAXi) returns the
%      Selectively Filtered Signal (Xs).
%   
%   INPUT
%   X is an M-by-1 vector with either the ribcage or
%       the abdominal signal.
%   FMAXi is an M-by-1 vector containing the filter
%       number with the maximum breathing power, which
%       provides the breathing frequency estimate.
%   Fs is a scalar value with the sampling frequency
%       (default=50Hz).
%
%   OUTPUT
%   Xs is an M-by-1 vector with the signal X
%       selectively filtered as described in [1].
%
%   EXAMPLE
%   [~,~,~,~,~,FMAXi]=filtBankRespir(RCG,N,Fs);  %Use Respiratory Filter Bank to get FMAXi
%   RCGs=SelectiveFilter(RCG,FMAXi,Fs);
%
%   VERSION HISTORY
%   2016_04_16 - Updated help (CARR).
%   2013_12_16 - Updated help header based on [2] and added default Fs (CARR).
%   201?_??_?? - Modified to work with the updated filter bank (CARR).
%   201?_??_?? - Modified to include Fs parameter (CARR).
%   2011_09_21 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] A. Aoude, R. E. Kearney, K. A. Brown, H. Galiana, and C. A.
%       Robles-Rubio,
%       "Automated Off-Line Respiratory Event Detection for the
%       Study of Postoperative Apnea in Infants,"
%       IEEE Trans. Biomed. Eng., vol. 58, pp. 1724-1733, 2011.
%   [2] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    xlen=length(X);

    % Define the cut-off frequencies
    dF = 0.2;
    Fl = [0:0.15:1.8]';
    Fh = Fl+dF;

    [numFilters,~] = size(Fl);

    Rp=0.1;
    Rs=50;
    n=[6;3;3;3;3;3;3;3;3;3;3;3;3];
    Wn={0.2/(Fs/2)};
    for index=2:numFilters
        Wn{index}=[Fl(index) Fh(index)]/(Fs/2);
    end

    Filt_signal=zeros(xlen,numFilters);

    for index=1:numFilters
        [b{index},a{index}] = ellip(n(index),Rp,Rs,Wn{index});

        % Filter the signals with the Filter Bank
        Filt_signal(:,index) = filtfilt(b{index},a{index},X);
    end
    clear a b Rp Rs n Wn Fl Fh dF Fs nc X;

    Xs = zeros(xlen,1);
    for kndex=1:numFilters
        index = find(FMAXi == kndex);
        Xs(index) = Filt_signal(index,kndex);  
    end
end