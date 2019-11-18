function [pattColor] = patternColor(patt)
%PATTERNCOLOR Returs the RGB color vector for the
%   specified input pattern.
%   [pattColor] = patternColor(patt)
%       outputs the RGB color definition for the pattern
%       in patt.
%
%   INPUT
%   patt is either a string with the pattern abbreviation
%       or an integer the pattern code as defined in [1].
%
%   OUTPUT
%   pattColor is an 1-by-3 vector with the RGB
%       color for the pattern in patt [1].
%
%   EXAMPLE
%   pattAbbrev='PAU';
%   [pattColor]=patternColor(pattAbbrev);
%   display(['Pattern color of ' pattAbbrev ' is: R = ' num2str(pattColor(1),'%1.4f') ', G = ' num2str(pattColor(2),'%1.4f') ', B = ' num2str(pattColor(3),'%1.4f') '.']);
%   [pattColor]=patternColor(patternCode(pattAbbrev));
%   display(['Pattern color of ' pattAbbrev ' is: R = ' num2str(pattColor(1),'%1.4f') ', G = ' num2str(pattColor(2),'%1.4f') ', B = ' num2str(pattColor(3),'%1.4f') '.']);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
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
%   patternAbbreviation, patternCode, patternName

    switch patt
        case 'PAU'
            pattColor=[0,0.5,1];             %Blue
            return;
        case patternCode('PAU')
            pattColor=[0,0.5,1];             %Blue
            return;
        case 'MVT'
            pattColor=[1,0.25,0.25];         %Red
            return;
        case patternCode('MVT')
            pattColor=[1,0.25,0.25];         %Red
            return;
        case 'UNK'
            pattColor=[0,0,0];               %Black
            return;
        case patternCode('UNK')
            pattColor=[0,0,0];               %Black
            return;
        case 'SYB'
            pattColor=[0.953,0.871,0.733];   %Beige
            return;
        case patternCode('SYB')
            pattColor=[0.953,0.871,0.733];   %Beige
            return;
        case 'ASB'
            pattColor=[0,1,0.5];             %Green
            return;
        case patternCode('ASB')
            pattColor=[0,1,0.5];             %Green
            return;
        case 'SIH'
            pattColor=[0.588,0.616,0.082];   %Olive
            return;
        case patternCode('SIH')
            pattColor=[0.588,0.616,0.082];   %Olive
            return;
        case 'BRE'
            pattColor=[0.66,0.87,0.52];      %Pastel Green
            return;
        case patternCode('BRE')
            pattColor=[0.66,0.87,0.52];      %Pastel Green
            return;
        case 'BDY'
            pattColor=[0.5,0,0.5];           %Purple
            return;
        case patternCode('BDY')
            pattColor=[0.5,0,0.5];           %Purple
            return;
        case 'NIL'
            pattColor=[0.941 0.941 0.941];	%Gray
            return;           
        case patternCode('NIL')               %not scored
            pattColor=[0.941 0.941 0.941];	%Gray
            return;
    end
end