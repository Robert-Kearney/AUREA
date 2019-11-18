function [W,E,Y,Mu_out] = nlmsFilt(X,D,M,Mu,Fs,ShowMsgs)
%Normalized Least-Mean-Square (LMS) adaptive filter.
%   For the standard LMS filter use lms.m.
%
%	[W,E,Y] = nlmsFilt(X,D,M,Mu,ShowMsgs)
%       returns the filter coefficients W at each time.
%
%   INPUT
%   X is an N-by-1 vector with the input
%        signal.
%   D is an N-by-1 vector with the desired
%        response signal.
%   M is a scalar value with the length (in
%       samples) of the filter.
%   Mu is a scalar value with the step size
%       parameter (gradient descent). If Mu is
%       set to inf (default), it will be set to
%       the maximum possible value (this is not yet
%       supported).
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages
%       should be sent to the standard output.
%
%   OUTPUT
%   W is an M-by-N vector containing the weights
%       of the filter at each time.
%   E is an N-by-1 vector containing the estimation
%       error (a.k.a. error signal).
%   Y is an N-by-1 vector containing the filter
%       output.
%   Mu_out is an N-by-1 vector containing the step
%       size parameter used at every sample.
%
%	EXAMPLE
%   %Adaptive Noise Canceller (ANC)
%   M=10;
%   Mu=0.1;
%   [W,E,Y]=nlmsFilt(REF,RCG,M,Mu);
%
%   VERSION HISTORY
%   2016_02_16 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] S. O. Haykin, Adaptive Filter Theory,
%       4 ed.: Prentice Hall, 2001.
%
%Copyright (c) 2016, Carlos Alejandro Robles Rubio
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

    if ~exist('Mu','var') || isempty(Mu)
        Mu=inf;
    end
    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    xlen=length(X);
    
    W=zeros(M,xlen);
    E=zeros(xlen,1);
    Y=zeros(xlen,1);
    Mu_out=nan(xlen,1);
    Mu_out(M-1)=inf;
    for index=M:xlen-1
        winIx=index:-1:index-M+1;

        Y(index)=W(:,index)'*X(winIx);
        E(index)=D(index)-Y(index);
        
        %Get the step-size parameter (Mu_out)
        if isinf(Mu)
            Mu_out(index)=Mu;
            
            %--------------------------------------------------------------
            %----- Add code to set Mu_out to a maximum possible value -----
            %--------------------------------------------------------------

        else
            Mu_out(index)=Mu;
        end
        
        W(:,index+1)=W(:,index)+Mu_out(index)*X(winIx)*conj(E(index))/(X(winIx)'*X(winIx));
    end
    Mu_out(M-1)=nan;
end