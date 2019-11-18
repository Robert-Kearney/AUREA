function [Xq] = orderStat(X,Nq,Q,flagCausal,Fs,verbose)
%ORDERSTAT Order statistics estimator
%	[Xq] = orderStat(X,Nq,Q,Fs) returns the moving
%       order statistic filter estimate for X.
%
%   INPUT
%   X is an M-by-1 vector with the signal under analysis.
%   Nq is a scalar value with the length (in sample points)
%       of the sliding window for the computation of Xq.
%   Q is a scalar value indicating the quantile. For
%       median set Q = 0.5.
%   flagCausal is a logical value indicating whether the filter
%       is causal (flagCausal = 1) or two-sided (flagCausal = 0).
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   verbose is a logical value indicating if the function
%       should output messages.
%
%   OUTPUT
%   Xq is an M-by-1 vector containing the order statistic
%       filtered X.
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

    if ~exist('flagCausal') | isempty(flagCausal)
        flagCausal=0;
    end
    
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    
    if ~exist('verbose') | isempty(verbose)
        verbose=0;
    end

    if verbose
        h=waitbar(0,'Calculating Order Stat...');
    end
    
    Nstart=floor(Nq/2)+1;
    if flagCausal
        Nstart=Nq;
    end
    
    Xq=nan(size(X));
    
    pointer=round(Q*(Nq-1))+1;
    obsVector=sortrows([X(1:Nq) [Nq:-1:1]'],1);
    for index=1:length(X)-Nq+1
        Xq(Nstart+index-1)=obsVector(pointer,1);
        obsAux=obsVector(obsVector(:,1)~=Nq,:);
        obsAux(:,2)=obsAux(:,2)+1;
        
        nextPt=X(Nq+index);
        ixGe=find(obsAux(:,1)>=nextPt);
        ixLt=find(obsAux(:,1)<nextPt);
        
        obsVector=nan(Nq,2);
        obsVector(ixGe+1,:)=obsAux(ixGe,:);
        obsVector(ixLt,:)=obsAux(ixLt,:);
        obsVector(ixGe(1),:)=[nextPt 1];
        if verbose
            waitbar(index/(length(X)-Nq+1))
        end
    end
    if verbose
        close(h);
    end
end