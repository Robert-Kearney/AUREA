function [MpStt] = patternsMarkedPoint(RespiratoryState,sttCode,MinStateLength,Fs,ShowMsgs)
%PATTERNSMARKEDPOINT Represents a sequence of patterns as a
%   marked-point process.
%	[MpStt] = patternsMarkedPoint(RespiratoryState,sttCode,MinStateLength,Fs,ShowMsgs)
%       returns the patterns in RespiratoryState with
%       code sttCode represented as a marked-point
%       process.
%
%   INPUT
%   RespiratoryState is an M-by-1 patterns signal with the
%       respiratory pattern classification at each sample.
%   sttCode is a K-by-1 vector with the numerical
%       codes (see [1]) for the patterns to be selected
%       from RespiratoryState.
%   MinStateLength is a scalar with the minimum
%       pattern length in samples (default = 2*Fs).
%   Fs is a scalar value with the sampling frequency
%       (default = 50 Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   MpStt is an S-by-3 matrix with the marked-point
%       process representation of RespiratoryState.
%       The columns correspond to:
%       (1) pattern start time (in samples),
%       (2) pattern length (in samples), and
%       (3) pattern type (code).
%
%   EXAMPLE
%   Fs=50;
%   ShowMsgs=false;
%   sttCode=[stateCode('PAU');stateCode('ASB')];
%   [MpStt]=patternsMarkedPoint(RespiratoryState,sttCode,Fs,ShowMsgs);
%   %Plot example
%   figure
%   stem(MpStt(MpStt(:,3)==stateCode('PAU'),1)./Fs,MpStt(MpStt(:,3)==stateCode('PAU'),2)./Fs,'Color',stateColor('PAU'));
%   hold on;
%   stem(MpStt(MpStt(:,3)==stateCode('ASB'),1)./Fs,MpStt(MpStt(:,3)==stateCode('ASB'),2)./Fs,'Color',stateColor('ASB'));
%   hold off;
%   xlabel('Time (s)');
%   ylabel('Length (s)');
%   legend('PAU','ASB');
%   xlim([0 60]);
%
%   VERSION HISTORY
%   2014_11_02 - Created by: Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%
%Copyright (c) 2014-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    %Set default values for parameters
    if ~exist('sttCode') | isempty(sttCode)
        sttCode=unique(RespiratoryState);
    end
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    if ~exist('MinStateLength') | isempty(MinStateLength)
        MinStateLength=2*Fs;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end

    %Get segments with codes equal to sttCode
    auxStates=signal2events(RespiratoryState);
    auxStates=auxStates(ismember(auxStates(:,3),sttCode),:);
    auxStates=auxStates((auxStates(:,2)-auxStates(:,1)+1)>=MinStateLength,:);
    numSegms=size(auxStates,1);
    
    %Arrange output values
    MpStt=nan(numSegms,3);
    MpStt(:,1)=auxStates(:,1);                  %Start time
    MpStt(:,2)=auxStates(:,2)-auxStates(:,1)+1; %Length
    MpStt(:,3)=auxStates(:,3);                  %Type
    
    %Sort by start time
    MpStt=sortrows(MpStt,1);
end