function [HMX] = hmaxStat(X,HRmin,HRmax,Nhmx,Ndec,Fs,Verb)
%HMAXSTAT Heart rate estimation based on spectrogram
%   [HMX] = hmaxStat(X,HRmin,HRmax,Nhmx,Ndec,Fs,Verb)
%       returns the heart rate estimated from X.
%
%   INPUT
%   X is an M-by-1 vector with either the ECG or PPG cardiac
%       signal.
%   HRmin is a scalar value with the minimum frequency represented
%       in HMX.
%   HRmin is a scalar value with the maximum frequency represented
%       in HMX.
%   Nhmx is a scalar value with the length (in sample points) of the
%       sliding window used to estimate HMX.
%   Ndec is a scalar value with the decimation factor.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   Verb is a logical value indicating if the function should output
%       messages.
%
%   OUTPUT
%   HMX is an M-by-1 vector containing the heart rate estimate from X.
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] D. Precup, C. A. Robles-Rubio, K. A. Brown, L. Kanbar,
%       J. Kaczmarek, S. Chawla, G. M. Sant’anna, and R. E. Kearney,
%       "Prediction of Extubation Readiness in Extreme Preterm
%       Infants Based on Measures of Cardiorespiratory Variability,"
%       in Conf. Proc. 34rd IEEE Eng. Med. Biol. Soc., San Diego, USA,
%       2012, pp. 5630-5633.
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

    deprecate(mfilename,{'filtBankCardiac'});
    
    if ~exist('Verb') | isempty(Verb)
        Verb=false;
    end
    
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    
    %Zero-mean
    Xzm=X-mean(X);
    
    %Decimation
    Xdec=decimate(X,Ndec);
    Nhmxdec=2*floor(Nhmx/Ndec/2)+1;
    
    %Spectrogram
    [S,F,~,~]=spectrogram(Xdec,Nhmxdec,Nhmxdec-1,Nhmxdec,Fs/Ndec);
    
    %Identification of frequency with maximum power
    ix_for_hr=(F>=HRmin & F<=HRmax);
    F_for_hr=F(ix_for_hr);
    [~,ics]=max(S(ix_for_hr,:),[],1);
    Fhr=F_for_hr(ics);
    
    %Interpolation
    tdec=[(Nhmxdec-1)/2+1:1:length(Xdec)-(Nhmxdec-1)/2]'./(Fs/Ndec);
    ttru=[Ndec*(Nhmxdec-1)/2+1:1:length(X)-Ndec*(Nhmxdec-1)/2]'./Fs;
    HMX=[nan(Ndec*(Nhmxdec-1)/2,1);spline(tdec,Fhr,ttru);nan(Ndec*(Nhmxdec-1)/2,1)];
end