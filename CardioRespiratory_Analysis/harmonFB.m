function [S,N] = harmonFB(X,F,M,Mu,idHarmons,FwdBwd,Fs,ShowMsgs)
%Harmonic Filter Bank.
%	[S,N] = harmonFB(X,F,M,Mu,idHarmons,FwdBwd,Fs,ShowMsgs)
%       returns the signal and noise components from quasi-
%       periodic signal X with instantaneous frequency F.
%
%   INPUT
%   X is an N-by-1 vector with the input
%        signal.
%   F is an N-by-1 vector with the instantaneous
%        respiratory frequency.
%   M is a scalar value with the length (in
%       samples) of the filters.
%   Mu is a scalar value with the step size
%       parameter for nLMS (see nlms.m).
%   idHarmons is a 1-by-H vectors with the desired
%       harmonic indices in S.
%   FwdBwd is a flag indicating if the signal should
%       be filtered forward and then backwards
%       (FwdBwd=true performs both passes).
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages
%       should be sent to the standard output.
%
%   OUTPUT
%   S is an N-by-1 vector containing the signal
%       component of X.
%   N is an N-by-1 vector containing the noise
%       component of X.
%
%	EXAMPLE
%   [S,N]=harmonFB(X,F,M,Mu,[1,2,3,4],true);
%
%   VERSION HISTORY
%   2016_02_16 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1]
%
%Copyright (c) 2016, Carlos Alejandro Robles Rubio
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

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    S=zeros(size(X));

    if iscolumn(idHarmons)
        idHarmons=idHarmons';
    end
    
    %Obtain ith harmonic
    for ixHarmonic=idHarmons;
    %Use VCO to create FM sinusoid
        baseFreq=F.*ixHarmonic;
        message=round(10000*(baseFreq-mean([min(baseFreq) max(baseFreq)]))./(diff([min(baseFreq) max(baseFreq)])/2))/10000;
        REF=vco(message,[min(baseFreq) max(baseFreq)],Fs);

        %Pass signal through adaptive notch filter to eliminate the harmonic
        %Forward
        [~,~,auxS]=nlms(REF,X,M,Mu);
        %Backward
        if FwdBwd
            [~,~,auxS]=nlms(flipud(REF),flipud(auxS),M,Mu);
            auxS=flipud(auxS);
        end
        S=S+auxS;
    end
    
    N=X-S;
end