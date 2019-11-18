function [W,E,Y,Mu_out] = lmsFilt(X,D,M,Mu,Fs,ShowMsgs)
%Standard Least-Mean-Square (LMS) adaptive filter
%	[W,E,Y,Mu_out] = lmsFilt(X,D,M,Mu,Fs,ShowMsgs)
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
%       the maximum value according to the
%       H-infinity criterion [1].
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
%   Mu=0.005;
%   [W,E,Y]=lmsFilt(REF,RCG,M,Mu);
%
%   VERSION HISTORY
%   2016_06_17 - Renamed to lmsFilt for compatibility with MATLAB R2016a (CARR).
%   2016_02_16 - Option to set Mu based on H-infinity criterion (CARR).
%   2016_02_15 - Renamed to lms and updated help (CARR).
%   2016_02_06 - Added output 'Y' and improved help (CARR).
%   201?_??_?? - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] S. O. Haykin, Adaptive Filter Theory,
%       4 ed.: Prentice Hall, 2001.
%
%Copyright (c) 2013-2016, Carlos Alejandro Robles Rubio
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

        %Get the step-size parameter (Mu_out)
        if isinf(Mu)
            %Maximum value under H-infinity criterion [1]
            Mu_out(index)=min(1./(X(winIx)'*X(winIx)),Mu_out(index-1));
        else
            Mu_out(index)=Mu;
        end
        
        Y(index)=W(:,index)'*X(winIx);
        E(index)=D(index)-Y(index);
        W(:,index+1)=W(:,index)+Mu_out(index)*X(winIx)*conj(E(index));
    end
    Mu_out(M-1)=nan;
end