function [Xzm] = zeroMean(X,Nzm,Algorithm,Fs)
%ZEROMEAN The zero-mean X.
%
%   [Xzm] = incrementalZeroMean(X,Nzm,Fs)
%       returns the zero-mean X using the
%       incremental (real-time ready) algorithm.
%
%   INPUT
%   X is an M-by-1 vector with the signal
%       of interest.
%   Nzm is a scalar value with the number
%       of samples required for estimating
%       the mean. If Algorithm=3 (incremental)
%       then Nzm is the minimum number of
%       initial samples.
%   Algorithm is a scalar value indicating the
%       method to estimate the zero-mean X.
%       Algorithm = 1: Global
%       Algorithm = 2: Local (window of Nzm)
%       Algorithm = 3: Incremental
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   Xzm is an M-by-1 vector containing the
%       zero-mean version of X.
%
%   VERSION HISTORY
%   2016_04_09 - Updated to use global mean (CARR).
%   2012_12_14 - Created by Carlos A. Robles-Rubio (CARR).

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    
    switch Algorithm
        case 1      %Global
            Xzm=X-nanmean(X);
        case 2      %Local
            b=ones(Nzm,1)./Nzm;
            Xzm=X-filter(b,1,X);
            Xzm(1:Nzm-1)=Xzm(Nzm);
        case 3      %Incremental
            Xzm=X-cumsum(X)./([1:1:length(X)]');
            Xzm(1:Nzm-1)=Xzm(Nzm);
        otherwise   %Error
            Xzm=nan(size(X));
            display(['Error, Algorithm does not exist']);
    end
end