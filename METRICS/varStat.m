function [V] = varStat(X,Nv,Nmu,Nq,Q,No,Fs)
%VARSTAT Normalized log-variance test statistic
%   [V] = varStat(X,Nv,Nmu,Nq,Q, No,Fs) returns the normalized variance
%   test statistic for signal X.
%   X is an M-by-1 vector with either the ribcage or the abdominal
%      signal.
%   Nv  length of the sliding window for computing the variance .
%   Nmu length of sliding window for coputiong the mean to remove 
%%  Nq the length (in sample points) of the
%      sliding window for the online Quiet Breathing power estimation.
%      If Nq is ommited, then the pause test statistic is computed
%      for the offline version.
%   Q - quartile to use for normalizarion
%   No -  
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   P is an M-by-1 vector containing the normalize variance values
%
%   Modified by CARR to include online analysis.
%   Modified by CARR to include Fs parameter
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.
%
%
%Copyright (c) 2012-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
%McGill University
%All rights reserved.
% 
%Redistribution and use in source and binary forms, with or without modification, are 
%permitted provided that the following conditions are met:
% 
%1. Redistributions of source code must retain the above copyright notice, this list of 
%   conditions and the following disclaimer.
% 
%2. Redistributions in binary form must reproduce the above copyright notice, this list of 
%   conditions and the following disclaimer in the documentation and/or other materials 
%   provided with the distribution.
% 
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
%EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
%MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
%COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
%EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
%HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

online=false;
useMedian=true;

if nargin>=3 & ~isempty(Nq)
    online=true;
end
if ~exist('Fs') | isempty(Fs)
    Fs=50;
end

xlen=length(X);

vx=momStat(X-momStat(X,1,Nmu,Fs),2,Nv,Fs);

if online
%     vxmedian=zeros(xlen,1);
    if useMedian
        auxqtl=zeros(xlen,1);
        increment=Nq-No;
        for index=Nq:increment:xlen
            auxqtl(index:index+increment-1)=quantile(vx(index-Nq+1:index),Q);
        end
        auxqtl(1:Nq-1)=auxqtl(Nq);
        vxmedian=auxqtl(1:xlen);
        
%         for index=Nq:xlen
%             vxmedian(index)=nanmedian(vx(index-Nq+1:index));
%         end
    else
        b=ones(Nq,1)./Nq;
        vxmedian=filternc(b,vx,1);
    end
    vxmedian(1:Nq-1)=vxmedian(Nq);
else
    vxmedian=nanmedian(vx);
end

V=log(vx./vxmedian);
end

