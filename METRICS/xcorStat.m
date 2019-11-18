function [RXY] = xcorStat(X,Y,Nx,WhichLags,Fs)
%XCORSTAT Crosscorrelation-coefficient lags
%   [RXY] = xcorStat(X,Y,Nx,WhichLags,Fs) returns the
%       crosscorrelation-coefficient lags for signals
%       X and Y.
%
%   INPUT
%   X is an M-by-1 vector with a signal.
%   Y is an M-by-1 vector with a signal.
%   Nx is a scalar value with the length (in sample points)
%       of the sliding window that estimates the
%       crosscorrelation-coefficient.
%   WhichLags is P-by-1 vector with the lags (in sample units)
%       that will be estimated (default=0).
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%
%   OUTPUT
%   RXY is an M-by-(P+2) matrix containing the
%       crosscorrelation-coefficient lags specified in
%       WhichLags. The two last columns contain the
%       maximum and minimum lags (in time units) from
%       the computed set.
%
%   VERSION HISTORY
%   V1.0: 2013_10_03 - Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] BMDE 519.
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

    if ~exist('WhichLags') | isempty(WhichLags)
        WhichLags=0;
    end    
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    slen=length(X);
    nlags=length(WhichLags);
    
    %Zero-mean
    Xzm=X-mean(X);
    Yzm=Y-mean(Y);
    
    %Crosscorrelation
    RXY=zeros(slen,nlags);
    b=ones(Nx,1)./Nx;
    Cxx=filternc(b,Xzm.*Xzm,2);
    Cyy=filternc(b,Yzm.*Yzm,2);
    parfor index=1:nlags
        if WhichLags(index)>=0
            myX=Xzm(1:end-WhichLags(index));
            myY=Yzm(1+WhichLags(index):end);
        else
            myX=Xzm(1+WhichLags(index):end);
            myY=Yzm(1:end-WhichLags(index));
        end
        Cxy=filternc(b,myX.*myY,2);
        Cxy(1:floor(Nx/2))=nan;
        Cxy(end-floor(Nx/2)+1:end)=nan;
        if WhichLags(index)>=0
            Cxy=[Cxy;nan(WhichLags(index),1)];
        else
            Cxy=[nan(WhichLags(index),1);Cxy];
        end
        RXY(:,index)=Cxy./sqrt(Cxx.*Cyy);
    end
    [~,maxix]=max(RXY,[],2);
    [~,minix]=min(RXY,[],2);
    RXY=[RXY WhichLags(maxix)./Fs WhichLags(minix)./Fs];
end