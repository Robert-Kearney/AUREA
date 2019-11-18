function [sigColor] = signalColor(sigAbbrev)
%SIGNALCOLOR Returs the RGB color vector for the
%	specified input signal.
%	[sigColor] = signalColor(sigAbbrev)
%		outputs the RGB color definition for the signal
%       in sigAbbrev.
%
%   INPUT
%   sigAbbrev is a string with the signal abbreviation
%       as defined in [1].
%
%   OUTPUT
%   sigColor is a 1-by-3 vector with the RGB
%       color for the signal in sigAbbrev [1].
%
%   EXAMPLE
%   sigAbbrev='RCG';
%   [sigColor]=signalColor(sigAbbrev);
%   display(['Signal color of ' sigAbbrev ' is: R = ' num2str(sigColor(1),'%1.4f') ', G = ' num2str(sigColor(2),'%1.4f') ', B = ' num2str(sigColor(3),'%1.4f') '.']);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    switch sigAbbrev
        case 'RCG'
            sigColor=[0,0,0];               %Black
            return;
        case 'ABD'
            sigColor=[0,0,1];               %Blue
            return;
        case 'PPG'
            sigColor=[0.5,0,0.5];           %Purple
            return;
        case 'SAT'
            sigColor=[0,0.8,0.7];           %Teal
            return;
        case 'ECG'
            sigColor=[1,0,0];               %Red
            return;
        case 'TMP'
            sigColor=[1,0.6,0];             %Orange
            return;
        case 'CO2'
            sigColor=[0.39,0.19,0];         %Brown
            return;
        case 'FiO2'
            sigColor = [0, 0,0];            %Black
        otherwise
            sigColor=nan;
            error(['Error in signalColor, input not recognized: ' sigAbbrev]);
            return;
    end
end