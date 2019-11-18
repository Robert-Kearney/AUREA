function [] = plotCardiorespiratoryData(Signals,SigLabels,Fs,RespStates,RespStatLabels,SigMarkers,SigColors)
%PLOTCARDIORESPIRATORYDATA Plots cardiorespiratory
%	data with the respiratory state.
%	[] = plotCardiorespiratoryData(Signals,SigLabels,Fs,RespStates,RespStatLabels,SigMarkers)
%		outputs a figure with the data in Signals
%       plotted as a function of time, with the
%       respiratory state defined in RespStates
%       included.
%
%   INPUT
%   Signals is an M-by-P matrix with the P cardiorespiratory
%       signals of length M to be plotted.
%   SigLabels is a 1-by-P struct array with the
%       labels for each of the P cardiorespiratory
%       signals.
%   Fs is a scalar value with the sampling frequency.
%   RespStates is an M-by-1 vector of integers
%       (with values from 1 to S) with the
%       respiratory state at each sample.
%   RespStatLabels is a 1-by-S struct array
%       with the labels for each of the S
%       respiratory states.
%   SigMarkers is a 1-by-P struct array with the
%       LineSpec plot definitions for each of the
%       P cardiorespiratory signals (see doc plot).
%   SigColors is a P-by-3 matrix with the RGB color
%       definition for each of the P input signals
%       (use stateColor) [2].
%
%   EXAMPLE
%   plotCardiorespiratoryData([RCG ABD PPG],{'RCG','ABD','PPG'},Fs,[respstt_RCGABD_ubmodkm respstt_RCGABD_kmeansX],{'Unbalanced Modified K means States','Regular Kmeans States'},{'-','--',':'},[signalColor('RCG');signalColor('ABD');signalColor('PPG')]);
%
%   VERSION HISTORY
%   2013_12_12: State and signal colors obtained from stateColor and signalColor function (CARR) [2].
%   2013_11_29: Added code for Breathing (BRE) and updated SIH and UNK (CARR).
%   Created by: Carlos A. Robles-Rubio.
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.
%   [2] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    [sigLen,numSig]=size(Signals);
    numScores=size(RespStates,2);
    Signals=Signals-ones(sigLen,1)*nanmedian(Signals);
    Signals=Signals./(ones(sigLen,1)*iqr(Signals));
    t=(1:1:sigLen)'./Fs;
    
    figure;
    set(gcf,'Position',[440 495 800 483]);
    offset=0;
    axes;
    hold on;
    for index=1:numSig
        plot(t,Signals(:,index)+offset,SigMarkers{index},'Color',SigColors(index,:),'LineWidth',2);
        if index<numSig
            offset=quantile(Signals(:,index),0.05)+offset-quantile(Signals(:,index+1),0.95);
        end
    end
    offset=offset+min(Signals(:,end))-1;
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('PAU'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('ASB'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('MVT'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('SYB'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('SIH'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('BRE'));
    patch([0 0 0 0]./Fs,[offset-1 offset-1 offset offset],stateColor('UNK'));
    scorLblOffset=zeros(numScores,1);
    for index=1:numScores
        Events=signal2events(RespStates(:,index));
        for jndex=1:size(Events,1)
            switch Events(jndex,3)
                case 1
                    colorCode=stateColor('PAU');
                case 2
                    colorCode=stateColor('ASB');
                case 3
                    colorCode=stateColor('MVT');
                case 4
                    colorCode=stateColor('SYB');
                case 5
                    colorCode=stateColor('SIH');
                case 6
                    colorCode=stateColor('BRE');
                case 99
                    colorCode=stateColor('UNK');
                otherwise
                    colorCode=stateColor('NIL');
            end
            patch([Events(jndex,1) Events(jndex,2) Events(jndex,2) Events(jndex,1)]./Fs,[offset-1 offset-1 offset offset],colorCode);
        end
        scorLblOffset(index)=offset-0.5;
        clear Events
        if index<numScores
            offset=offset-1.5;
        end
    end
    legend([SigLabels,'PAU','ASB','MVT','SYB','SIH','BRE','UNK'],'Location','EastOutside','Orientation','vertical');
    xlabel(['Time (s)']);
    ylim([offset-2 quantile(Signals(:,1),0.99)]);
    grid(gca,'minor')
    hold off;
    set(gca,'YTick',flip(scorLblOffset),'YTickLabel',flip(RespStatLabels));
end