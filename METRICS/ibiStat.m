function [IBI,EOI,EOE] = ibiStat(X,Navg,Nsmo,Notl,Fs,ShowMsgs)
%FREQSTAT Estimation of Inter-breath Interval (IBI)
%	from RIP signals.
%   [IBI,EOI,EOE] = ibiStat(X,Navg,Nsmo,Notl,Fs,ShowMsgs)
%       returns the IBI estimates from signal X.
%
%   INPUT
%   X is an M-by-1 vector with the signal
%       under analysis.
%   Navg is a scalar value with the length (in
%       sample points) of the sliding window used
%       to estimate the moving mean.
%   Nsmo is a scalar value with the length
%       (in sample points) of the smoothing
%       window (for noise reduction).
%   Notl is a scalar value with the threshold
%       of half-breath interval to eliminate
%       outliers.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   IBI is an M-by-1 vector containing the
%       Inter-breath Interval.
%   EOI is an M-by-1 vector containing a train
%       of impulses indicating the end of inspiration
%       (breath peaks).
%   EOE is an M-by-1 vector containing a train
%       of impulses indicating the end of expiration
%       (breath troughs).
%
%	EXAMPLE
%   Navg=51;
%   Nsmo=13;
%   Notl=1;
%   [IBI,EOI,EOE]=ibiStat(RCG,Navg,Nsmo,Notl);
%
%   VERSION HISTORY
%   2016_02_07 - Added EOI and EOE to output (CARR).
%   2016_02_03 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1]
%
%Copyright (c) 2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('Nsmo','var') || isempty(Nsmo)
        Nsmo=1;
    end
    if ~exist('Notl','var') || isempty(Notl)
        Notl=1;
    end
    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    %Perform breath segmentation
    BreathPeaksTroughs=breathSegmentation(X,Navg,Nsmo,Fs,false);
    BreathPeaksTroughs=sortrows(BreathPeaksTroughs,1);
    
    %Obtain the half-breath intervals
    auxHBI=diff(BreathPeaksTroughs(:,1));   %The half breath intervals
    
    %Eliminate half-breath interval outliers (i.e., too short)
    ixWrongBr=find(auxHBI<=Notl);
    BreathPeaksTroughs(ixWrongBr,1)=nan;
    BreathPeaksTroughs(ixWrongBr+1,1)=nan;
    BreathPeaksTroughs=BreathPeaksTroughs(~isnan(BreathPeaksTroughs(:,1)),:);
    
    %Get trains of impulses
    EOI=zeros(size(X));
    EOI(BreathPeaksTroughs(BreathPeaksTroughs(:,2)==1,1))=1;
    EOE=zeros(size(X));
    EOE(BreathPeaksTroughs(BreathPeaksTroughs(:,2)==0,1))=1;
    
    %Obtain breath information
    BreathInfo=breathInformation(X,BreathPeaksTroughs,Fs,ShowMsgs);
    numBreaths=size(BreathInfo,1);  %Number of breaths
    BreathLn=BreathInfo(:,2);       %Length
    BreathSt=BreathInfo(:,1);       %Start
    BreathEn=BreathSt+BreathLn-1;   %End

    %Estimate Inter-breath Intervals
    IBI=nan(size(X));
    for ixBreath=1:numBreaths
        IBI(BreathSt(ixBreath):BreathEn(ixBreath))=BreathLn(ixBreath)/Fs;
    end
end