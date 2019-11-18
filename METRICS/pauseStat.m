function [P] = pauseStat(X,Np,Nq,Fs,QB)
%PAUSESTAT Pause test statistic
%   [P] = pauseStat(X,Np,Nq,Fs) returns the pause test statistic for
%   signal X.
%   X is an M-by-1 vector with either the ribcage or the abdominal
%      signal.
%   Np is a scalar value with the length (in sample points) of the
%      sliding window.
%   Nq is a scalar value with the length (in sample points) of the
%      sliding window for the online Quiet Breathing power estimation.
%      If Nq is ommited, then the pause test statistic is computed
%      for the offline version.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   QB - frequecny band for quiet breathing Hz . Default is [0.4 2.]
%   P is an M-by-1 vector containing the Pause test statistic
%      values.
%
%   Modified by CARR to include online analysis.
%   Modified by CARR to include Fs parameter
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.

online=false;

if nargin>=3 & ~isempty(Nq)
    online=true;
end
if ~exist('Fs') | isempty(Fs)
    Fs=50;
end
if nargin <5,
    QB=[.4 2];
end

xlen=length(X);

% Band-pass filter with frequencies in the quiet breathing band only
b=ones(Np,1)./Np;

[b1,a1]=ellip(5,0.01,50,QB/(Fs/2));
xbp=filtfilt(b1,a1,X);
px=filter2S(b,xbp.^2);

if online
    pxmedian=zeros(xlen,1);
    for index=Nq:xlen
        pxmedian(index)=nanmedian(px(index-Nq+1:index));
    end
    pxmedian(1:Nq-1)=pxmedian(Nq);
else
    pxmedian=nanmedian(px);
end

% if mod(Nq,2)==1
%     pxmedian=medfilt1([zeros(floor(Nq/2),1);px],Nq,blksz);
% else
%     pxmedian=medfilt1([zeros(floor(Nq/2)-1,1);px],Nq,blksz);
% end
% pxmedian=pxmedian(1:xlen);

P=sqrt(px./pxmedian);
end

