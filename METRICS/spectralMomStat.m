function [Smu] = spectralMomStat(X,power,Nmu,Fs)
%SPECTRALMOMSTAT Central moment estimator
%   [Mu] = spectralMomStat(X,power,Nmu,Fs) returns the central
%       spectral moment estimate for X in a window of length Nmu.
%
%   INPUT
%   X is an M-by-1 vector with the signal under analysis.
%   power is a scalar value indicating the moment's power.
%   Nmu is a scalar value with the length (in sample points) of the
%       sliding window for the computation of Mu.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%
%   OUTPUT
%   M is an M-by-1 vector containing the spectral power moment
%       estimates for X.
%
%   Version 1.0: Carlos A. Robles-Rubio.
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

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    b=ones(Nmu,1)./Nmu;
    Xavg=filternc(b,X,2);
    Xzm=X-Xavg;

    xlen=size(X,1);

    Nstart=floor(Nmu/2);
    Nfft=2^nextpow2(Nmu);
    f=Fs/2*linspace(0,1,Nfft/2+1);
    fBW=f(2);

    Y=nan(Nfft/2+1,xlen);
    for index=1:xlen-Nmu+1
        aux=abs(fft(Xzm(index:index+Nmu-1),Nfft)/Nmu).^2;
        Y(:,index+Nstart)=aux(1:Nfft/2+1)./trapz(f,aux(1:Nfft/2+1));
    end
    Savg=fBW*(f*Y)';

    if power==1
        Smu=Savg;
    else
        meanAuxMat=ones(Nfft/2+1,1)*Savg';
        freqAuxMat=(f'*ones(1,xlen)-meanAuxMat).^power;
        Smu=fBW*sum(freqAuxMat.*Y,1)';
    end

end