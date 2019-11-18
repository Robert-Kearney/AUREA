function [ sigUnit ] = signalUnit( sigAbbrev )
%SIGNALUNIT Returns the signal's unit.
%	[sigUnit] = signalUnit(sigAbbrev)
%		outputs the unit of the signal sigAbbrev.
%
%   INPUT
%   sigAbbrev is a string with the state abbreviation
%       as defined in [1].
%
%   OUTPUT
%   sigUnit is a string with the unit for the state in
%       stateAbbrev [1].
%
%   EXAMPLE
%   sigAbbrev='RCG';
%   [sigUnit]=signalUnit(sigAbbrev);
%   display(['Unit of ' sigAbbrev ' is: ' sigUnit]);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions, Carlos A. Robles-Rubio (CARR).
%	2014_04_30: Created by Lara J. Kanbar (LJK).
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

    switch sigAbbrev
        case 'RCG'
            sigUnit='AU';
            return;
        case 'ABD'
            sigUnit='AU';
            return;
        case 'PPG'
            sigUnit='AU';
            return;
        case 'SAT'
            sigUnit='%';
            return;
        case 'ECG'
            sigUnit='AU';
            return;
        case 'TMP'
            sigUnit='\circC';
            return;
        case 'BRE'
            sigUnit=6;
            return;
        case 'CO2'
            sigUnit='-';
            return;
        case 'FiO2'
            sigUnit = '%';
           return; 
        otherwise
            error(['Error in stateCode, input not recognized: ' sigAbbrev]);
            sigUnit=nan;
            return;
    end
end