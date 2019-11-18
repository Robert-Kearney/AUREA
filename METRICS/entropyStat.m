function [E] = entropyStat(X,Nent,kent,flagCausal,flagRealTime,Fs,verbose)
%ENTROPYSTAT Entropy test statistic
%   [E] = entropyStat(X,Nent,kent,flagCausal,flagRealTime,Fs,verbose)
%       returns the entropy statistic for signal X as
%       described in [1].
%
%   INPUT
%   X is an M-by-1 vector with the photoplethysmography
%       (PPG) signal.
%   Nent is a scalar value with the length (in sample
%       points) of the sliding window.
%   kent is a scalar value with the number of bins
%       used to estimate the pdf for entropy
%       calculation.
%   flagCausal is a logical value indicating if the
%       filter is causal (flagCausal = 1) or two-sided
%       (flagCausal = 0).
%   flagRealTime is a logical value indicating if the
%       computation is offline (flagRealTime=0 ->
%       faster) or real-time (flagRealTime=1 -> more
%       resistant to nonstationarities).
%   Fs is a scalar value with the sampling frequency
%       (default=50Hz).
%   verbose is a logical value indicating if the
%       function should output messages.
%
%   OUTPUT
%   E is an M-by-1 vector containing the Entropy
%       statistic values. E is described in equation 1
%       in [1], and was developed as a time-varying
%       implementation of the movement artifact
%       detector from [2].
%
%   VERSION HISTORY
%   2013-01-03: Added verbose and selection between offline/real-time (CARR).
%   2013-01-02: Improved offline computation using matrix calculations (CARR).
%   Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "A New Movement Artifact Detector for Photoplethysmographic
%       Signals," in Conf. Proc. 35th IEEE Eng. Med. Biol. Soc.,
%       Osaka, Japan, 2013, pp. 2295-2299.
%   [2] N. Selvaraj, Y. Mendelson, K. H. Shelley, D. G. Silverman, and K. H. Chon,
%       "Statistical approach for the detection of motion/noise
%       artifacts in Photoplethysmogram,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc.,
%       Boston, MA, USA, 2011, pp. 4972-4975.
%
%
%Copyright (c) 2011-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('flagCausal') | isempty(flagCausal)
        flagCausal=0;
    end
    
    if ~exist('flagRealTime') | isempty(flagRealTime)
        flagRealTime=1;
    end

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    
    if ~exist('verbose') | isempty(verbose)
        verbose=0;
    end
    
    if flagRealTime
        E=nan(size(X));
        for index=1:length(X)-Nent+1
            mywin=index:index+Nent-1;
            [mypdf,mycen]=hist(X(mywin),kent);
            mypdf=mypdf./(Nent);
            aux=mypdf.*log(mypdf);
            aux(isnan(aux))=0;
            E(index+floor(Nent/2))=-sum(aux)./log(kent);
            if(verbose && mod(index,round((length(X)-Nent+1)/10))==0)
                display(['Entropy completion: ' num2str(round(index*100/(length(X)-Nent+1))/100)])
            end
        end
    else
        display('entropyStat: Warning, non real-time option has not been verified');
        Nstart=floor(Nent/2);
        if flagCausal
            Nstart=Nent-1;
        end

        xlen=size(X,1);

        Y=nan(Nent,xlen);
        for index=1:xlen-Nent+1
            Y(:,index+Nstart)=X(index:index+Nent-1);
        end
        [Mypdfs,~]=hist(Y,kent);
        Mypdfs=Mypdfs./Nent;
        aux=Mypdfs.*log(Mypdfs);
        aux(isnan(aux))=0;
        E=-sum(aux)'./log(kent);

        E(1:Nstart)=nan;
        if ~flagCausal
            E(end-(Nstart-1):end)=nan;
        end
    end
end