function [F] = adaptFreqStat(X,M,Mu,Fmin,Fmax,Fres,Fs,Verb)
%ADAPTFREQSTAT Instantaneous frequency estimation based on LMS adaptive filter.
%   [F] = adaptFreqStat(X,M,Mu,Fmin,Fmax,Fres,Fs,Verb)
%       returns the instantaneous frequency
%       estimated from X.
%
%   INPUT
%   X is an M-by-1 vector with the cardiac or respiratory
%       signal.
%   M is a scalar value with the length (in sample points) of the
%       of the LMS adaptive filter used to estimate F.
%   Mu is a scalar value with the step-size parameter
%       of the LMS adaptive filter used to estimate F.
%   Fmin is a scalar value with the minimum frequency
%       represented in F.
%   Fmax is a scalar value with the maximum frequency
%       represented in F.
%   Fres is a scalar value with the resolution of the
%       frequency estimator.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   Verb is a logical value indicating if the function should output
%       messages.
%
%   OUTPUT
%   HMX is an M-by-1 vector containing the heart rate estimate from X.
%
%   VERSION HISTORY
%   V1.0: 2013_02_09 - Carlos A. Robles-Rubio.
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

    if ~exist('Verb') | isempty(Verb)
        Verb=false;
    end
    
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    W=lms(X,[X(2:end);0],M,Mu);
    
    f=linspace(Fmin/Fs,Fmax/Fs,floor((Fmax-Fmin)/Fres)+1)';

    freqmat=exp(-1i*2*pi.*f*[1:1:M]);
    F_all=1./(abs(1-freqmat*W).^2);
    
    [~,ixF]=max(F_all);
    F=f(ixF).*Fs;
end