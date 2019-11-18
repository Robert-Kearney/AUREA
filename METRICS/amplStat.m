function [AMP] = amplStat(X,Nt,Nm,Nq,Q,No,Normalize,Fs)
%AMPLSTAT Movement artifact test statistic
%   [AMP] = amplStat(X,Nt,Nm,Nq,Q,No,Normalize,Fs)
%       returns the amplitude movement artifact test
%       statistic for signal X.
%
%   INPUT
%   X is an M-by-1 vector with a quasi-periodic
%       cardiorespiratory signal.
%   Nt is a scalar value with the period (in sample points)
%       corresponding to the frequency with maximum
%       power in the population of X.
%   Nm is a scalar value with the length (in sample points)
%       of the sliding window that estimates
%       the local mean and RMS.
%   Nq is a scalar value with the length (in sample points)
%       of the sliding window for the real-time
%       (time-varying) normalization of AMP. If Nq is
%       ommited, then the offline version of the
%       statistic is computed.
%   Q is a scalar value ranging from 0 to 1
%       indicating the normalization quantile.
%   No is a scalar value with the number of samples
%       by which successive estimations of the Q-quantile
%       overlap. Maximum overlap = Nq-1.
%   Normalize is a boolean flag indicating whether the
%       output should be normalized by Qth quantile or
%       not (default=true).
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   AMP is an M-by-1 vector containing the movement
%       artifact test statistic described in [1].
%
%   EXAMPLE
%	[AMP]=amplStat(PPG,Nt,Nm,Nq,0.1,Nq-Fs,true,Fs);
%
%   VERSION HISTORY
%   2014_04_29 - Added option to return non-normalized stat (CARR).
%   2012_12_14 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "A New Movement Artifact Detector for Photoplethysmographic
%       Signals," in Conf. Proc. 35th IEEE Eng. Med. Biol. Soc.,
%       Osaka, Japan, 2013, pp. 2295-2299.
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

    realtime=false;

    xlen=length(X);
    
    if exist('Nq') & ~isempty(Nq) & xlen>Nq
        realtime=true;
    end

    if ~exist('Normalize') | isempty(Normalize)
        Normalize=true;
    end
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    %Zero-mean
    Xzm=X-momStat(X,1,Nm,Fs);

    %Moving-average
    Xavg=momStat(Xzm,1,Nt,Fs);

    %RMS
    b=ones(Nm,1)./Nm;
    Ax=(sqrt(filter2S(b,Xavg.^2)));

    if Normalize
        %Estimate Ax_qtl
        if realtime
            auxqtl=zeros(xlen,1);
            increment=Nq-No;
            for index=Nq:increment:xlen
                auxqtl(index:index+increment-1)=quantile(Ax(index-Nq+1:index),Q);
            end
            auxqtl(1:Nq-1)=auxqtl(Nq);
            Ax_qtl=auxqtl(1:xlen);
        else
            Ax_qtl=quantile(Ax,Q);
        end

        %Normalization
        AMP=log(Ax./Ax_qtl);
    else
        AMP=Ax;
    end
end