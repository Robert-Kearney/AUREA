function [pattName] = patternName(patt)
%PATTERNNAME Returs the name of the input pattern.
%   [pattName] = patternName(patt)
%       outputs a string with the full name of
%       the pattern in patt.
%
%   INPUT
%   patt is either a string with the pattern abbreviation
%       or an integer the pattern code as defined in [1].
%
%   OUTPUT
%   pattName is a string with the name of the
%       pattern in patt [1].
%
%   EXAMPLE
%   pattAbbrev='PAU';
%   [pattName]=patternName(pattAbbrev);
%   display(['Pattern name of ' pattAbbrev ' is: ' pattName '.']);
%   [pattName]=patternName(stateCode(pattAbbrev));
%   display(['Pattern name of ' pattAbbrev ' is: ' pattName '.']);
%
%   VERSION HISTORY
%   2015_03_31: Created by Carlos A. Robles-Rubio (CARR).
%
%   References:
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
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
%   patternAbbreviation, patternCode, patternColor

    switch patt
        case 'PAU'
            pattName='Pause';
            return;
        case patternCode('PAU')
            pattName='Pause';
            return;
        case 'MVT'
            pattName='Movement artifact';
            return;
        case patternCode('MVT')
            pattName='Movement artifact';
            return;
        case 'UNK'
            pattName='Unknown';
            return;
        case patternCode('UNK')
            pattName='Unknown';
            return;
        case 'SYB'
            pattName='Synchronous-breathing';
            return;
        case patternCode('SYB')
            pattName='Synchronous-breathing';
            return;
        case 'ASB'
            pattName='Asynchronous-breathing';
            return;
        case patternCode('ASB')
            pattName='Asynchronous-breathing';
            return;
        case 'SIH'
            pattName='Sigh';
            return;
        case patternCode('SIH')
            pattName='Sigh';
            return;
        case 'BRE'
            pattName='Breathing';
            return;
        case patternCode('BRE')
            pattName='Breathing';
            return;
        case 'BDY'
            pattName='Bradycardia';
            return;
        case patternCode('BDY')
            pattName='Bradycardia';
            return;
        case 'NIL'
            pattName='No pattern assigned';
            return;           
        case patternCode('NIL')
            pattName='No pattern assigned';
            return;
    end
end