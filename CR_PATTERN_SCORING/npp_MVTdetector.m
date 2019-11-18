function [isMVT,npp_thres] = npp_MVTdetector(X,lambda,Nt,Nm,CnMVT,CyMVT,avgNPP,stdNPP,Fs)
%NPP_MVTDETECTOR Non-Periodic Power detector of MVT
%   [isMVT] = npp_MVTdetector(X,lambda,Nt,Nm,CnMVT,CyMVT,Fs)
%       detects movement artifact based on the NPP
%       statistic [1] estimated from signal X.

%
%   INPUT
%   X is an M-by-1 vector with a quasi-periodic
%       cardiorespiratory signal.
%   lambda is a scalar in the range (0,1) with
%       the value of the forgetting factor.
%   Nt is a scalar value with the period (in
%       sample points) corresponding to the
%       frequency with maximum power in the
%       population of X (default=21).
%   Nm is a scalar value with the length (in
%       sample points) of the sliding window
%       that estimates the local mean and RMS
%       (default=251).
%   CnMVT is a scalar value that indicates the
%       center of the non-MVT cluster in the NPP
%       range of values. If nothing is input it
%       is estimated from the first hour of data.
%   CyMVT is a scalar value that indicates the
%       center of the MVT cluster in the NPP range
%       of values.  If nothing is input it is
%       estimated from the first hour of data.
%   avgNPP is a scalar with the mean value of NPP
%       for the population. It is used to standardize
%       the NPP statistic. If nothing is input it
%       is estimated from the NPP computed from X.
%   stdNPP is a scalar with the standard deviation
%       of NPP for the population. It is used to
%       standardize the NPP statistic. If nothing
%       is input it is estimated from the NPP
%       computed from X.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   isMVT is an M-by-1 vector containing a boolean
%       flag indicating whether movement artifact
%       is present or not.
%   npp_thres is an M-by-1 vector containing the
%       time-varying threshold used with the NPP
%       statistic to detect MVT at each sample.
%
%   EXAMPLE
%   [isMVT,npp_thres]=npp_MVTdetector(PPG,0.9);
%
%   VERSION HISTORY
%   2014_05_05 - Function returns time-varying threshold and standardizes NPP (CARR).
%   2014_04_28 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "A New Movement Artifact Detector for Photoplethysmographic
%       Signals," in Conf. Proc. 35th IEEE Eng. Med. Biol. Soc.,
%       Osaka, Japan, 2013, pp. 2295-2299.
%   [2] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    if ~exist('Nt') | isempty(Nt)
        Nt=21;
    end
    if ~exist('Nm') | isempty(Nm)
        Nm=251;
    end
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    
    xlen=length(X);
    
    %Estimate non-normalized NPP statistic
    NPP=amplStat(X,Nt,Nm,[],[],[],false,Fs);
    
    %Standardize NPP statistic
    if ~exist('avgNPP') | isempty(avgNPP)
        avgNPP=mean(NPP);
    end
    if ~exist('stdNPP') | isempty(stdNPP)
        stdNPP=std(NPP);
    end
    NPP=(NPP-avgNPP)./stdNPP;
    
    %Initialize cluster centers if they are not input
    if ~exist('CnMVT') | ~exist('CyMVT') | isempty('CnMVT') | isempty('CyMVT')
        myvar=NPP(1:3600*Fs);    %Use the first hour of the signal to estimate the cluster centers
        [~,Cent]=kmeans(myvar,2,'options',statset('MaxIter',1000),'start',[min(myvar);max(myvar)]);
        CnMVT=Cent(1);
        CyMVT=Cent(2);
    end
    
    %Run kmeans iteratively to classify as MVT or not
    isMVT=nan(xlen,1);
    npp_thres=nan(xlen,1);
    for n=1:xlen
        %Record threshold
        npp_thres(n)=(CyMVT-CnMVT)/2+CnMVT;
        
        %Clustering
        [~,auxIx]=min(abs([NPP(n)-CnMVT NPP(n)-CyMVT]));
        isMVT(n)=auxIx-1;
        
        %Update
        if ~isMVT(n)
            CnMVT=(lambda-1)*NPP(n)/(lambda^n-1)+lambda*(lambda^(n-1)-1)*CnMVT/(lambda^n-1);
        else
            CyMVT=(lambda-1)*NPP(n)/(lambda^n-1)+lambda*(lambda^(n-1)-1)*CyMVT/(lambda^n-1);
        end
    end
end