function [BreathInfo] = breathInformation(X,BreathPeaksTroughs,Fs,ShowMsgs)
%BREATHINFORMATION Obtains breath-by-breath information from RIP signals
%	[BreathInfo] = breathInformation(X,BreathPeaksTroughs,Fs,ShowMsgs)
%       returns the information of each breath in
%       BreathPeaksTroughs.
%
%   INPUT
%   X is an M-by-1 vector with either a ribcage or
%       an abdominal RIP signal (preferably from a
%       SYB or ASB segment only).
%   BreathPeaksTroughs is an M-by-2 vector containing
%       the breaths' Peaks and Troughs information, as
%       output by breathSegmentation. Col1 is the occurrence
%       time, and Col2 is the type (0: Trough, 1: Peak).
%   Fs is a scalar value with the sampling frequency
%       (default = 50 Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   BreathInfo is an N-by-5 vector containing the breaths'
%       information:
%       - Col1 is the breath start time (in samples),
%       - Col2 the breath total time (in samples) (Ttot),
%       - Col3 the inspiration time (in samples) (Ti),
%       - Col4 the expiration time (in samples) (Te), and
%       - Col5 the breath amplitude (in a.u.) (Height).
%
%   EXAMPLE
%   Fs=50;
%   Nba=251;
%   Nbn=5;
%   BreathPeaksTroughs=breathSegmentation(RCG,Nba,Nbn,Fs,false);
%   BreathInfo=breathInformation(RCG,BreathPeaksTroughs,Fs,ShowMsgs);
%
%   VERSION HISTORY
%   2014_10_28 - Created by: Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Detection of Breathing Segments in Respiratory Signals,"
%       in Conf. Proc. 34th IEEE Eng. Med. Biol. Soc.,
%       San Diego, USA, 2012, pp. 6333-6336.
%
%
%Copyright (c) 2014-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    %Set default values for parameters
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end

    %Identify the troughs
    trous=BreathPeaksTroughs(BreathPeaksTroughs(:,2)==0,1);
    peaks=BreathPeaksTroughs(BreathPeaksTroughs(:,2)==1,1);
    
    %Identify the breaths' start and end times
    breathSt=trous(1:end-1);
    breathEn=trous(2:end)-1;
    
    %Define output
    numBreaths=length(breathSt);
    BreathInfo=nan(numBreaths,5);
    
    %Calculate breath parameters and update output
    for index=1:numBreaths
        %Breath start time (in s)
        BreathInfo(index,1)=breathSt(index);
        
        %Breath total time (in s). Ttot
        BreathInfo(index,2)=(breathEn(index)-breathSt(index)+1);
        
        %Inspiration time (in s). Ti
        ixPeak=find(and(peaks>=breathSt(index),peaks<=breathEn(index)));
        BreathInfo(index,3)=(peaks(ixPeak)-breathSt(index));
        
        %Expiration time (in s). Te
        BreathInfo(index,4)=(breathEn(index)-peaks(ixPeak)+1);
        
        %Breath amplitude (in a.u.). Height
        maxX=X(peaks(ixPeak));
        minX=min(X(breathSt(index)),X(breathEn(index)));
        BreathInfo(index,5)=maxX-minX;
    end
end