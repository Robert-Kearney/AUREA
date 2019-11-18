function [M] = mvtStat(X,Nm,Fs,ShowMsgs)
%MVTSTAT Movement test statistic
%   [M]  = mvtStat(X,Nm,Fs) returns the movement test statistic for
%   signal X.
%   X is an M-by-1 vector with either the ribcage or the abdominal
%      signal.
%   Nm is a scalar value with the length (in sample points) of the
%      sliding window.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output (default = false).
%   M is an M-by-1 vector containing the movement test statistic
%      values.
%
%   2015_04_16 - Modified to work with filtBankRespir (CARR).
%   Modified by CARR to include Fs parameter
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    %Get the maximum power at each band
    [~,~,MaxPWR_MV,MaxPWR_RR,~,~]=filtBankRespir(X,Nm,Fs,ShowMsgs);

    %Estimate the metric br2mvpw_Xxxxxx_filtbnk
    M=(MaxPWR_RR-MaxPWR_MV)./(MaxPWR_RR+MaxPWR_MV);
end