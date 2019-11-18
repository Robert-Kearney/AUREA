function [RMS] = rmsStat(RC,AB,Nr,Fs)
%RMSSTAT RMS test statistic
%   [RMS] = rmsStat(RC,AB,Nr) returns the RMS test statistic from
%   signals RC and AB.
%   RC and AB are M-by-1 vectors with the ribcage and the abdominal
%      signals respectively.
%   Nr is a scalar value with the length (in sample points) of the
%      sliding window.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   RMS is an M-by-1 vector containing the RMS test statistic
%      values.
%
%   Modified by CARR to include Fs parameter
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    b=ones(Nr,1)./Nr;

    px=filter2S(b,RC.^2);
    py=filter2S(b,AB.^2);

    RMS=sqrt(px)+sqrt(py);
end

