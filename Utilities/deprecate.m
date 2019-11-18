function [] = deprecate(replacementFunctions)
%DEPRECATE Shows a deprecated message.
%	[] = deprecate(replacementFunctions)
%		displays a message in the standard output
%       indicating that the called function is
%       deprecated, and that 'replacementFunctions'
%       should be used instead.
%
%   INPUT
%   replacementFunctions is a cell array of strings
%       with the list of functions that should be
%       used to replace 'functionName'.
%
%   EXAMPLE
%   %The first line of the deprecated function 'aurea' is:
%   deprecate({'CardiorespiratoryMetrics';'respState_originalAUREA'});
%
%   VERSION HISTORY
%   2015_04_16 - Outputs also the name of caller function (CARR).
%   2014_01_13 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1]
%
%
%Copyright (c) 2014-2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    callSeq=dbstack;

    display([' ']);
    display(['******************** Deprecated ********************']);
    display(['The function ''' callSeq(2).name '''']);
    display(['is no longer supported, and will be removed from']);
    display(['the repository in the near future.']);
    display([' ']);
    display(['Use the following functions instead:']);
    for index=1:length(replacementFunctions)
        display(['- ' replacementFunctions{index}]);
    end
    if size(callSeq,1)>=3
        display(' ');
        display(['''' callSeq(2).name ''' was called by ''' callSeq(3).name '''']);
    end
    display(['****************************************************']);
    display([' ']);
end