function [PHI,FMAXi_ABD] = asynchStat(RCG,ABD,Na,Fs,ShowMsgs)
%ASYNCHSTAT Asynchrony test statistic
%   [PHI,FMAXi_ABD] = asynchStat(RCG,ABD,Na,Fs) returns the phase estimate between
%   signals RCG and ABD.
%   RCG and ABD are M-by-1 vectors with the ribcage and abdominal
%      signals respectively.
%   Na is a scalar value with the length (in sample points) of
%      the sliding window.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output (default = false).
%   PHI is an M-by-1 vector containing the Asynchrony test statistic
%      values in percent of 180 degrees.
%   FMAXi_ABD is an M-by-1 vector containing the filter number with the
%      maximum breathing power, which provides the breathing frequency
%      estimate.
%
%   2015_04_16 - Modified to work with filtBankRespir (CARR).
%   Modified by CARR to actually compute fmax from ABD and not from RCG
%   Modified by CARR to include Fs parameter
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Proc. 33rd IEEE Ann. Int. Conf. Eng. Med. Biol. Soc.,
%       Boston, USA, 2011, pp. 3201-3204.

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    [~,~,~,~,~,FMAXi_ABD]=filtBankRespir(ABD,Na,Fs,ShowMsgs);
    rcg=SelectiveFilter(RCG,FMAXi_ABD,Fs);
    abd=SelectiveFilter(ABD,FMAXi_ABD,Fs);
    
    %binary conversion and output u=0 when the signals are the same and u=1 
    %when different
    u=xor((sign(rcg)+1)/2,(sign(abd)+1)/2);
    b=ones(Na,1)/Na;

    %takes the moving average of window of size N of u
    %hence returns value between 0 and 1 representing the degree of assynchrony
    PHI=filter2S(b,u);
end