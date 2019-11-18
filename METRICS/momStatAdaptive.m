function [Mu] = momStatAdaptive(X,power,Nmu,Nmu_max,Fs)
%MOMSTAT Central moment estimator
%	[Mu] = momStat(X,power,Nmu,Fs) returns the central moment
%       estimate for X in a window of length Nmu.
%
%   INPUT
%   X is an M-by-1 vector with the signal under analysis.
%   power is a scalar value indicating the moment's power.
%   Nmu is an M-by-1 vector with the length (in sample points)
%       of the sliding window for the computation of Mu
%       at each sample.
%   Nmu_max is a scalar value with the maximum value expected
%       for Nmu in the population of X.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%
%   OUTPUT
%   M is an M-by-1 vector containing the power moment
%       estimates for X.
%
%   VERSION HISTORY
%   V1.0: 2013_02_07 - Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1]
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

    xlen=length(X);
    Xavg=zeros(xlen,1);
    
    Lmax=floor(Nmu_max/2);
    for index=Lmax+1:xlen-Lmax
        L=floor(Nmu(index)/2);
        winIx=index-Lmax:1:index+Lmax;
        
        b=zeros(Nmu_max,1);
        b(Lmax+1-L:Lmax+1+L)=1./Nmu(index);
        
        Xavg(index)=X(winIx)'*b;
    end

    if power==1
        Mu=Xavg;
    else
        Mu=momStatAdaptive((X-Xavg).^power,1,Nmu,Nmu_max,Fs);
    end

end