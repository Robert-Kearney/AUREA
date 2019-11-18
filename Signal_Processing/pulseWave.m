function [PW] = pulseWave(N,Period,DutyCycle,Phase,K,Fs)
%PULSEWAVE Pulse Wave
%   [PW] = pulseWave(N,Period,DutyCycle,Phase,K,Fs)
%      returns a square pulse signal with the given
%       parameters.
%
%   INPUT
%   N is a scalar with the desired length
%       for PW.
%   Period is a scalar with the period (in seconds)
%       of the pulse wave.
%   DutyCycle is a scalar with the proportion
%       of time that PW = 1 during each period.
%   Phase is a scalar with the phase (in rad)
%       of PW.
%   K is a scalar with the phase (in rad)
%       of PW.
%   Fs is a scalar value with the sampling
%      frequency (default=50Hz).
%
%   OUTPUT
%   PW is an N-by-1 vector containing the
%      square pulse wave.
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
%
%   References:
%   [1] http://en.wikipedia.org/wiki/Pulse_wave
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
    t=(1:1:N)'./Fs;
    
    PW=ones(N,1).*DutyCycle/Period;
    
    parfor k=1:K
        PW=PW+(2/(k*pi)).*sin(k*pi*DutyCycle./Period).*cos(2*pi*k*(t-Phase)./Period);
    end
    PW=floor((sign(PW-1/2)+1)/2);
end