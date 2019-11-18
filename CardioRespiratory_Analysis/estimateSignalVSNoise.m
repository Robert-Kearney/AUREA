function [S,N,R,Ps,Pn,Tau] = estimateSignalVSNoise(RCG,ABD,PPG,fR,MaxH_fR,fC,MaxH_fC,M,Mu,epsilon,Fs)
%ESTIMATESIGNALVSNOISE Estimation of the signal and noise components of RIP and PPG.
%   [S,N,R,Ps,Pn,Tau] = estimateSignalVSNoise(RCG,ABD,PPG,fR,MaxH_fR,fC,MaxH_fC,M,Mu,epsilon,Fs)
%       returns the signal and noise components of RCG,
%       ABD, and PPG.
%
%   INPUT
%   RCG is an M-by-1 vector with the data from the
%       ribcage signal.
%   ABD is an M-by-1 vector with the data from the
%       abdomen signal.
%   PPG is an M-by-1 vector with the data from the
%       photoplethysmography signal.
%   fR is an M-by-1 vector with the instantaneous
%       respiratory frequency.
%   MaxH_fR is a scalar value indicating the maximum
%       harmonic of fR with significant power.
%   fC is an M-by-1 vector with the instantaneous
%       cardiac frequency.
%   MaxH_fC is a scalar value indicating the maximum
%       harmonic of fC with significant power.
%   M is a scalar value with the order of the adaptive
%       LMS filters for estimation of signal components.
%   Mu is a scalar value with the step size parameter
%       of the adaptive LMS filters.
%   epsilon is a scalar value with the maximum average
%       error for convergence of the LMS filters
%       (default=0.01).
%   Fs is a scalar value with the sampling
%      frequency (default=50Hz).
%
%   OUTPUT
%   S is an M-by-3 matrix with the signal component of
%       RCG, ABD, and PPG respectively.
%   N is an M-by-3 matrix with the noise component of
%       RCG, ABD, and PPG respectively.
%   R is a 1-by-3 vector with the SNR value for
%       RCG, ABD, and PPG respectively.
%	Ps is a 1-by-3 vector with the power of the signal
%       component for RCG, ABD, and PPG respectively.
%	Pn is a 1-by-3 vector with the power of the noise
%       component for RCG, ABD, and PPG respectively.
%   Tau is a 3-by-1 vector with the average time constant
%       for the LMS filters for RCG, ABD, and PPG
%       respectively.
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
    if ~exist('epsilon') | isempty(epsilon)
        epsilon=0.01;
    end
    
    xlen=length(RCG);

    %% SNR of PPG
    TauPPG=[];
    remPPG=PPG; %The remainder of the signal is set to the original PPG
    for cHarmonicIndex=1:MaxH_fC
        %The ith harmonic of the cardiac frequency
        baseFreq=fC*cHarmonicIndex;
        baseFreq(baseFreq>=Fs/2)=Fs/2-0.0001;
        
        %Use VCO to create FM sinusoid
        message=round(10000*(baseFreq-mean([min(baseFreq) max(baseFreq)]))./(diff([min(baseFreq) max(baseFreq)])/2))/10000;
        refFMsin=vco(message,[min(baseFreq) max(baseFreq)],Fs);
        
        %Estimate time constant of LMS filter for reference FM signal
        Rxx=zeros(M,M);
        for index=M:xlen
            Rxx=Rxx+refFMsin(index-M+1:index)*refFMsin(index-M+1:index)';
        end
        Rxx=Rxx./(xlen-M+1);
        if sum(sum(isnan(Rxx)))>0
            break;  %All harmonics have been eliminated
        end
        
        [~,Sigma,~]=svd(Rxx);
        TauPPG=[TauPPG;ceil(1/(2*Mu*mean(diag(Sigma))))];
        
        %Pass signal through adaptive notch filter to eliminate the harmonic
        [~,remPPG]=lmsFilt(refFMsin,remPPG,M,Mu);
    end
    for rHarmonicIndex=1:MaxH_fR
        %The ith harmonic of the respiratory frequency
        baseFreq=fR*rHarmonicIndex;
        baseFreq(baseFreq>=Fs/2)=Fs/2-0.0001;
        
        %Use VCO to create FM sinusoid
        message=round(10000*(baseFreq-mean([min(baseFreq) max(baseFreq)]))./(diff([min(baseFreq) max(baseFreq)])/2))/10000;
        refFMsin=vco(message,[min(baseFreq) max(baseFreq)],Fs);
        
        %Estimate time constant of LMS filter for reference FM signal
        Rxx=zeros(M,M);
        for index=M:xlen
            Rxx=Rxx+refFMsin(index-M+1:index)*refFMsin(index-M+1:index)';
        end
        Rxx=Rxx./(xlen-M+1);
        if sum(sum(isnan(Rxx)))>0
            break;  %All harmonics have been eliminated
        end
        
        [~,Sigma,~]=svd(Rxx);
        TauPPG=[TauPPG;ceil(1/(2*Mu*mean(diag(Sigma))))];
        
        %Pass signal through adaptive notch filter to eliminate the harmonic
        [~,remPPG]=lmsFilt(refFMsin,remPPG,M,Mu);
        if min(baseFreq>=Fs/2)
            break;
        end
    end
    
    %Signal and Noise components of PPG
    N_PPG=remPPG;       %The BGN is the remainder after notch filtering harmonics
    S_PPG=PPG-remPPG;   %The rest is the signal component
    
    %The convergence time
    TauPPG=max(TauPPG);
    nconv=ceil(-TauPPG*log(epsilon));
    
    %The power of Signal and Noise components
    myS_PPG=S_PPG(nconv+1:end)-mean(S_PPG(nconv+1:end));
    myN_PPG=N_PPG(nconv+1:end)-mean(N_PPG(nconv+1:end));
    Ps_PPG=myS_PPG'*myS_PPG/length(myS_PPG);
    Pn_PPG=myN_PPG'*myN_PPG/length(myN_PPG);
    
    %The SNR of PPG
    SNR_PPG=10*log10(Ps_PPG/Pn_PPG);

    %% SNR of RCG
    TauRCG=[];
    remRCG=RCG; %The remainder of the signal is set to the original RCG
    for rHarmonicIndex=1:MaxH_fR
        %The ith harmonic of the respiratory frequency
        baseFreq=fR*rHarmonicIndex;
        baseFreq(baseFreq>=Fs/2)=Fs/2-0.0001;
        
        %Use VCO to create FM sinusoid
        message=round(10000*(baseFreq-mean([min(baseFreq) max(baseFreq)]))./(diff([min(baseFreq) max(baseFreq)])/2))/10000;
        refFMsin=vco(message,[min(baseFreq) max(baseFreq)],Fs);
        
        %Estimate time constant of LMS filter for reference FM signal
        Rxx=zeros(M,M);
        for index=M:xlen
            Rxx=Rxx+refFMsin(index-M+1:index)*refFMsin(index-M+1:index)';
        end
        Rxx=Rxx./(xlen-M+1);
        if sum(sum(isnan(Rxx)))>0
            break;  %All harmonics have been eliminated
        end
        
        [~,Sigma,~]=svd(Rxx);
        TauRCG=[TauRCG;ceil(1/(2*Mu*mean(diag(Sigma))))];
        
        %Pass signal through adaptive notch filter to eliminate the harmonic
        [~,remRCG]=lmsFilt(refFMsin,remRCG,M,Mu);
        if min(baseFreq>=Fs/2)
            break;
        end
    end
    
    %Signal and Noise components of RCG
    N_RCG=remRCG;       %The BGN is the remainder after notch filtering harmonics
    S_RCG=RCG-remRCG;   %The rest is the signal component
    
    %The convergence time
    TauRCG=max(TauRCG);
    nconv=ceil(-TauRCG*log(epsilon));
    
    %The power of Signal and Noise components
    myS_RCG=S_RCG(nconv+1:end)-mean(S_RCG(nconv+1:end));
    myN_RCG=N_RCG(nconv+1:end)-mean(N_RCG(nconv+1:end));
    Ps_RCG=myS_RCG'*myS_RCG/length(myS_RCG);
    Pn_RCG=myN_RCG'*myN_RCG/length(myN_RCG);
    
    %The SNR of RCG
    SNR_RCG=10*log10(Ps_RCG/Pn_RCG);
    
    %% SNR of ABD
    TauABD=[];
    remABD=ABD; %The remainder of the signal is set to the original ABD
    for rHarmonicIndex=1:MaxH_fR
        %The ith harmonic of the respiratory frequency
        baseFreq=fR*rHarmonicIndex;
        baseFreq(baseFreq>=Fs/2)=Fs/2-0.0001;
        
        %Use VCO to create FM sinusoid
        message=round(10000*(baseFreq-mean([min(baseFreq) max(baseFreq)]))./(diff([min(baseFreq) max(baseFreq)])/2))/10000;
        refFMsin=vco(message,[min(baseFreq) max(baseFreq)],Fs);
        
        %Estimate time constant of LMS filter for reference FM signal
        Rxx=zeros(M,M);
        for index=M:xlen
            Rxx=Rxx+refFMsin(index-M+1:index)*refFMsin(index-M+1:index)';
        end
        Rxx=Rxx./(xlen-M+1);
        if sum(sum(isnan(Rxx)))>0
            break;  %All harmonics have been eliminated
        end
        
        [~,Sigma,~]=svd(Rxx);
        TauABD=[TauABD;ceil(1/(2*Mu*mean(diag(Sigma))))];
        
        %Pass signal through adaptive notch filter to eliminate the harmonic
        [~,remABD]=lmsFilt(refFMsin,remABD,M,Mu);
        if min(baseFreq>=Fs/2)
            break;
        end
    end
    
    %Signal and Noise components of ABD
    N_ABD=remABD;       %The BGN is the remainder after notch filtering harmonics
    S_ABD=ABD-remABD;   %The rest is the signal component
    
    %The convergence time
    TauABD=max(TauABD);
    nconv=ceil(-TauABD*log(epsilon));
    
    %The power of Signal and Noise components
    myS_ABD=S_ABD(nconv+1:end)-mean(S_ABD(nconv+1:end));
    myN_ABD=N_ABD(nconv+1:end)-mean(N_ABD(nconv+1:end));
    Ps_ABD=myS_ABD'*myS_ABD/length(myS_ABD);
    Pn_ABD=myN_ABD'*myN_ABD/length(myN_ABD);
    
    %The SNR of ABD
    SNR_ABD=10*log10(Ps_ABD/Pn_ABD);
    
    %% Final outputs
    S=[S_RCG S_ABD S_PPG];
    N=[N_RCG N_ABD N_PPG];
    R=[SNR_RCG SNR_ABD SNR_PPG];
    Ps=[Ps_RCG Ps_ABD Ps_PPG];
    Pn=[Pn_RCG Pn_ABD Pn_PPG];
    Tau=[TauRCG;TauABD;TauPPG];
end