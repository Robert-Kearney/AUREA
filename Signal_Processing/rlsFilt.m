function [Y,E,A] = rlsFilt(X,D,M,l,d,Fs,ShowMsgs)
%Standard Recursive Least Squares (RLS) adaptive filter
%   [Y,E,A] = rlsFilt(X,D,M,l,d,Fs,ShowMsgs)
%       returns the output of the adaptive RLS
%       filter with input X and desired output D.
%
%   INPUT
%   X is an N-by-1 vector with the input
%        signal.
%   D is an N-by-1 vector with the desired
%        response signal.
%   M is a scalar value with the length (in
%       samples) of the filter.
%   l is a scalar value with the forgetting
%       factor of RLS. The term 1/(1-l) represents
%       a rough measure of memory [1].
%   d is a scalar value with the initialization
%       of the P matrix.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages
%       should be sent to the standard output.
%
%   OUTPUT
%   Y is an N-by-1 vector containing the filter
%       output.
%   E is an N-by-1 vector containing the estimation
%       error (a.k.a. error signal).
%   A is an (M+1)-by-(N+1) matrix with the values
%      of the filter parameters at each sample.
%
%	EXAMPLE
%   %Adaptive Noise Canceller (ANC)
%   l=;
%   d=;
%   [Y,E,A]=rlsFilt(REF,RCG,M,l,d);
%
%   VERSION HISTORY
%   2016_02_16 - Renamed to rlsFilt (CARR).
%   2016_02_16 - Updated and improved help (CARR).
%   2011_??_?? - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] S. O. Haykin, Adaptive Filter Theory,
%       4 ed.: Prentice Hall, 2001.
%
%Copyright (c) 2011-2016, Carlos Alejandro Robles Rubio
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

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    xlen=length(X);

    %Initialization
    Y=zeros(xlen,1);
    E=zeros(xlen,1);
    alpha=zeros(xlen,1);
    A=zeros(M+1,length(X)+1);
    P=eye(M+1)./d;

    segm=1:M+1;
    segm=segm';

    for n=0:xlen-1-M
        winIx=segm+n;
        alpha(winIx(end))=D(winIx(end))-X(winIx)'*A(:,winIx(end)-1);
        gTop=P*X(winIx);
        gBot=l+X(winIx)'*P*X(winIx);
        g=gTop./gBot;
        P=P./l-g*X(winIx)'*P./l;
        A(:,winIx(end))=A(:,winIx(end)-1)+alpha(winIx(end)).*g;
        Y(winIx(end))=X(winIx)'*A(:,winIx(end));
    end

    E=D-Y;

end