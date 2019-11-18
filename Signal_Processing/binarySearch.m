function [Ix] = binarySearch(X,key,imin,imax,verbose)
%BINARYSEARCH Binary Search
%	[Ix] = binarySearch(X,key,imin,imax,verbose) returns
%       X(Ix)=key.
%
%   INPUT
%   X is an M-by-1 vector with the signal under analysis.
%   key is a scalar with the value that is being searched.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   verbose is a logical value indicating if the function
%       should output messages.
%
%   OUTPUT
%   Ix is a scalar containing the index where X(Ix)=key.
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   http://en.wikipedia.org/wiki/Binary_search_algorithm
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

    %Test if array is empty
    if imax<imin
        %Set is empty, so return value showing not found
        Ix=(imin+imax)/2;
    else
        %Calculate midpoint to cut set in half
        imid=round(mean([imin,imax]));

        %Comparison
        if X(imid)>key
        	%key is in lower subset
            Ix=binarySearch(X,key,imin,imid-1,verbose);
        elseif X(imid)<key
        	%key is in upper subset
            Ix=binarySearch(X,key,imid+1,imax,verbose);
        else
        	%key has been found
            Ix=imid;
        end
    end
end