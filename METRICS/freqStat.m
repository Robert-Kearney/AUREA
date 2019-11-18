function [FZC,FZCr,FZCf] = freqStat(X,Nf,Navg,bSmooth,Fs)
%FREQSTAT Estimation of Respiratory and Heart Rate
%	for use with RIP and PPG respectively.
%   [FZC,FZCr,FZCf] = freqStat(X,Nf,Navg,bSmooth,Fs)
%       returns the instantaneous frequency estimates
%       of the signal X using approximate FM
%       demodulation.
%
%   INPUT
%   X is an M-by-1 vector with the signal
%       under analysis.
%   Nf is a scalar value with the length (in
%       sample points) of the sliding window.
%   Navg is a scalar value with the length
%       (in sample points) of the smoothing
%       window (for noise reduction).
%   bSmooth is an S-by-1 vector with the coefficients
%       of smoothing FIR filter at the output.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   FZC is an M-by-1 vector containing the
%       Zero Crossings Approximate FM demodulation.
%       The zero-holded signal is filtered using the
%       FIR filter defined by bSmooth.
%   FZCr is an M-by-1 vector containing the
%       Zero Crossings Approximate FM demodulation
%       on the rising edge. The zero-holded signal
%       is filtered using the FIR filter defined by
%       bSmooth.
%   FZCf is an M-by-1 vector containing the
%       Zero Crossings Approximate FM demodulation
%       on the falling edge. The zero-holded signal
%       is filtered using the FIR filter defined by
%       bSmooth.
%
%	EXAMPLE
%   [FZC,FZCr,FZCf]=freqStat(RCG,Nf,Navg,bSmooth,Fs);
%
%   VERSION HISTORY
%   2014_03_26 - Added help: Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] R. Wiley,
%       "Approximate FM Demodulation Using Zero Crossings,"
%       IEEE Trans. Commun.,
%       vol. 29, pp. 1061-1065, 1981.
%
%
%Copyright (c) 2013-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    %Binarize the signals and obtain the rising edge
    Xm1=momStat(X,1,Nf,Fs);
    Xm2=momStat(X,1,Navg,Fs);
    Xbin=double(Xm2>Xm1);
    Xdbin=[0;diff(Xbin)];
    

%% Zero Crossings Approximate FM demodulation (FZC) zero-hold
    FZCr=zeros(size(X));
    FZCf=zeros(size(X));
    sigd=Xdbin;
    ixp=find(sigd==1);
    stp=[1;ixp];
    enp=[ixp-1;length(FZCr)];
    ixn=find(sigd==-1);
    stn=[1;ixn];
    enn=[ixn-1;length(FZCf)];
    for index=1:length(stp)
        FZCr(stp(index):enp(index))=Fs./(enp(index)-stp(index)+1);
    end
    for index=1:length(stn)
        FZCf(stn(index):enn(index))=Fs./(enn(index)-stn(index)+1);
    end
    
    if(~exist('bSmooth') | isempty(bSmooth))
        bSmooth=1;
    end
    FZCr=filter2S(bSmooth,FZCr);
    FZCf=filter2S(bSmooth,FZCf);
    
    FZC=(FZCr+FZCf)./2;
end