function [A,T,M] = periodAmplitudeStat(X,Nm,Ns,Nq,Q,No,Fs)
%PERIODAMPLITUDESTAT Period-amplitude analysis statistics
%   [A,T,M] = periodAmplitudeStat(X,Nm,Ns,Nq,Q,No,Fs) returns the
%       period-amplitude statisics for signal X.
%
%   INPUT
%   X is an M-by-1 vector with a quasi-periodic
%       cardiorespiratory signal.
%   Nm is a scalar value with the length (in sample points)
%       of the sliding window that estimates
%       the local mean.
%   Ns is a scalar value with the length (in sample points)
%       of the smoothing sliding window for X.
%   Nq is a scalar value with the length (in sample points)
%       of the sliding window for the real-time
%       (time-varying) normalization of A, T, and M. If Nq
%       is ommited, then the offline version of the
%       statistic is computed.
%   Q is a scalar value ranging from 0 to 1
%       indicating the normalization quantile.
%   No is a scalar value with the number of samples
%       by which successive estimations of the Q-quantile
%       overlap. Maximum overlap = Nq-1.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   A is an M-by-1 vector containing the amplitude
%       statistic from period-amplitude analysis [1].
%   T is an M-by-1 vector containing the period
%       statistic from period-amplitude analysis [1].
%   M is an M-by-1 vector containing the slope
%       statistic from period-amplitude analysis [1].
%
%   VERSION HISTORY
%   V1.0: 2013_03_15 - Carlos A. Robles-Rubio.
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

    realtime=false;

    if exist('Nq') & ~isempty(Nq)
        realtime=true;
    end

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    xlen=length(X);

    %Breath segmentation
    BreathData=sortrows(breathSegmentation(X,Nm,Ns,Fs),1);
    if BreathData(1,1)~=1
        BreathData=[[1 ~BreathData(1,2)];BreathData];
    end
    if BreathData(end,1)~=xlen
        BreathData=[BreathData;[xlen ~BreathData(end,2)]];
    end
    numPoints=size(BreathData,1);
    
    %Smoothing
    b=ones(Ns,1)./Ns;
    Xsmo=filternc(b,X,2);
    
    %Half-breath--by--half-breath Statistics
    Apre=nan(xlen,1);
    Tpre=nan(xlen,1);
    for index=1:numPoints-1
        st=BreathData(index,1);
        en=BreathData(index+1,1);
        Apre(st:en)=Xsmo(en)-Xsmo(st);
        Tpre(st:en)=(en-st+1)/Fs;
    end
    Mpre=abs(Apre./Tpre);

    %Estimate Apre_qtl, Tpre_qtl, and Mpre_qtl
    if realtime
        auxqtl_A=zeros(xlen,1);
        auxqtl_T=zeros(xlen,1);
        auxqtl_M=zeros(xlen,1);
        increment=Nq-No;
        for index=Nq:increment:xlen
            auxqtl_A(index:index+increment-1)=quantile(Apre(index-Nq+1:index),Q);
            auxqtl_T(index:index+increment-1)=quantile(Tpre(index-Nq+1:index),Q);
            auxqtl_M(index:index+increment-1)=quantile(Mpre(index-Nq+1:index),Q);
        end
        auxqtl_A(1:Nq-1)=auxqtl_A(Nq);
        auxqtl_T(1:Nq-1)=auxqtl_T(Nq);
        auxqtl_M(1:Nq-1)=auxqtl_M(Nq);
        Apre_qtl=auxqtl_A(1:xlen);
        Tpre_qtl=auxqtl_T(1:xlen);
        Mpre_qtl=auxqtl_M(1:xlen);
    else
        Apre_qtl=quantile(Apre,Q);
        Tpre_qtl=quantile(Tpre,Q);
        Mpre_qtl=quantile(Mpre,Q);
    end
    
    %Normalization
    A=Apre./Apre_qtl;
    T=Tpre./Tpre_qtl;
    M=Mpre./Mpre_qtl;
end