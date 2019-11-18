function [Mu] = momStat(X,power,Nmu,Fs)
%MOMSTAT Central moment estimator
%	[Mu] = momStat(X,power,Nmu,Fs) returns the central
%       moment estimate for X in a window of length Nmu.
%
%   INPUT
%   X is an M-by-1 vector with the signal under
%       analysis.
%   power is a scalar value indicating the moment's
%       power.
%   Nmu is a scalar value with the length (in sample
%       points) of the sliding window for the
%       computation of Mu.
%   Fs is a scalar value with the sampling frequency
%       (default=50Hz).
%
%   OUTPUT
%   Mu is an M-by-1 vector containing the power moment
%       estimates for X.
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
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

    b=ones(Nmu,1)./Nmu;
    Xavg=filter2S(b,X);

    if power==1
        Mu=Xavg;
    else
        Mu=filter2S(b,(X-Xavg).^power);
    end

end