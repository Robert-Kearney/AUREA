function [pattAbbrev] = patternAbbreviation(pattCode)
%PATTERNABBREVIATION Returs the acronym of the specified pattern.
%   [pattAbbrev] = patternAbbreviation(pattCode)
%       outputs the acronym for the pattern code
%       in pattCode.
%
%   INPUT
%   pattCode is a scalar value with a numerical pattern
%       code [1].
%
%   OUTPUT
%   pattAbbrev is a string with the pattern abbreviation
%       as defined in [1].
%
%   EXAMPLE
%   pattCode=1;
%   [pattAbbrev]=patternAbbreviation(pattCode);
%   display(['Acronym of pattern #' num2str(pattCode) ': ' pattAbbrev]);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] McCRIB Group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%   LICENSE
%   Copyright (c) 2013-2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney,
%   McGill University
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without modification,
%   are permitted provided that the following conditions are met:
%
%   1. Redistributions of source code must retain the above copyright notice,
%      this list of conditions and the following disclaimer.
% 
%   2. Redistributions in binary form must reproduce the above copyright notice,
%      this list of conditions and the following disclaimer in the documentation
%      and/or other materials provided with the distribution.
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
%   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
%   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
%   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
%   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
%   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%   TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
%   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   SEE ALSO
%   patternCode, patternColor, patternName

    switch pattCode
        case 1
            pattAbbrev='PAU';
            return;
        case 3
            pattAbbrev='MVT';
            return;
        case 99
            pattAbbrev='UNK';
            return;
        case 4
            pattAbbrev='SYB';
            return;
        case 2
            pattAbbrev='ASB';
            return;
        case 5
            pattAbbrev='SIH';
            return;
        case 6
            pattAbbrev='BRE';
            return;
        case 11
            pattAbbrev='BDY';
            return;
        case 0
            pattAbbrev = 'NIL';
        otherwise
            pattAbbrev=nan;
            error(['Error in patternAbbreviation, input not recognized: ' num2str(pattCode)]);
            return;
    end
end