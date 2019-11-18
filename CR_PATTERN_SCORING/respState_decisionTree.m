function [RespiratoryState,StateCodes,ClassificationParameters] = respState_decisionTree(GoldEach,MetricsEach,ClassificationParameters,ShowMsgs)
%RESPSTATE_DECISIONTREE Estimates the instantaneous respiratory state using the decision tree algorithm.
%   [RespiratoryState,StateCodes,ClassificationParameters] = respState_decisionTree(GoldEach,MetricsEach,ClassificationParameters,ShowMsgs)
%       estimates the instantaneous respiratory state
%       using the decision tree algorithm described
%       in [1].
%
%   INPUT
%   GoldEach is a 1-by-K struct array containing
%       the "gold standard" labels for each sample.
%   MetricsEach is a 1-by-K struct array containing
%       the struct array Metrics (output from CardiorespiratoryMetrics)
%       for each of the K records under analysis.
%   ClassificationParameters is a struct array
%       as output by respState_decisionTree.
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output.
%
%   OUTPUT
%   RespiratoryState is a 1-by-K struct array with
%       the respiratory state classification for
%       each of the K records under analysis.
%       Each cell is a vector with the classification
%       values.
%   StateCodes is an struct array with the numerical
%       code for each of the respiratory states
%       in RespiratoryState.
%   ClassificationParameters is a struct array
%       with the classification parameters after
%       training with GoldEach and MetricsEach.
%
%   EXAMPLE
%   %For training   
%   [~,~,ClassificationParameters]=respState_decisionTree(GoldEach,MetricsEach,[],ShowMsgs);
%   %For testing
%   [RespiratoryState,StateCodes]=respState_decisionTree([],MetricsEach,ClassificationParameters,ShowMsgs);
%
%   VERSION HISTORY
%   2016_04_09 - Deprecated the function (CARR).
%   2012_01_31 - Created by Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] A. Aoude, R. E. Kearney, K. A. Brown, H. Galiana,
%       and C. A. Robles-Rubio,
%       "Automated Off-Line Respiratory Event Detection
%       for the Study of Postoperative Apnea in Infants,"
%       IEEE Trans. Biomed. Eng., vol. 58, pp. 1724-1733,
%       2011.
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

    deprecate({'resPatt_decTree'});

    verbose([mfilename ': start'],ShowMsgs);

%% Verify that the necessary metrics are input
    verbose([char(9) 'Verifying correct input metrics ...'],ShowMsgs);
    metricNames=fields(MetricsEach{1});
    if sum(strcmp(metricNames,'resppwr_RCGxxx_win2sid'))~=1
        error(['MetricsEach is missing ''resppwr_RCGxxx_win2sid''']);
    end
    if sum(strcmp(metricNames,'resppwr_ABDxxx_win2sid'))~=1
        error(['MetricsEach is missing ''resppwr_ABDxxx_win2sid''']);
    end
    if sum(strcmp(metricNames,'br2mvpw_RCGxxx_filtbnk'))~=1
        error(['MetricsEach is missing ''br2mvpw_RCGxxx_filtbnk''']);
    end
    if sum(strcmp(metricNames,'br2mvpw_ABDxxx_filtbnk'))~=1
        error(['MetricsEach is missing ''br2mvpw_ABDxxx_filtbnk''']);
    end
    if sum(strcmp(metricNames,'taphase_RCGABD_bpbinsg'))~=1
        error(['MetricsEach is missing ''taphase_RCGABD_bpbinsg''']);
    end
    verbose([char(9) 'Verifying correct input metrics ... done'],ShowMsgs);

%% Initialize function
    verbose([char(9) 'Initializing variables ...'],ShowMsgs);
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    StateCodes.PAU=stateCode('PAU');
    StateCodes.ASB=stateCode('ASB');
    StateCodes.MVT=stateCode('MVT');
    StateCodes.SYB=stateCode('SYB');
    StateCodes.SIH=stateCode('SIH');
    StateCodes.BRE=stateCode('BRE');
    StateCodes.UNK=stateCode('UNK');

    numFiles=length(MetricsEach);
    lengthEach=zeros(numFiles,1);
    for index=1:numFiles
        lengthEach(index)=length(MetricsEach{index}.resppwr_RCGxxx_win2sid);
%         lengthEach(index)=length(MetricsEach{index}.varnorm_RCGxxx_win2sid);
    end
    
    verbose([char(9) 'Initializing variables ... done'],ShowMsgs);

%% Training
    if ~exist('ClassificationParameters') | isempty(ClassificationParameters)
        verbose([char(9) 'Training (obtain thresholds) ...'],ShowMsgs);

        verbose([char(9) char(9) 'Select all non-NaN samples in all metrics used ...'],ShowMsgs);
        AuxMetrics={};
        AuxGold=[];
        AuxFields={'resppwr_RCGxxx_win2sid';'resppwr_ABDxxx_win2sid';'br2mvpw_RCGxxx_filtbnk';'br2mvpw_ABDxxx_filtbnk';'taphase_RCGABD_bpbinsg'};
%         AuxFields={'varnorm_RCGxxx_win2sid';'varnorm_ABDxxx_win2sid';'nppnorm_RCGxxx_win2sid';'nppnorm_ABDxxx_win2sid';'difbrea_RCGABD_dtbinsg'};
        for mndex=1:length(AuxFields)
            AuxMetrics=setfield(AuxMetrics,AuxFields{mndex},[]);
        end
        for index=1:numFiles
            ixGood=ones(lengthEach(index),1);
            for mndex=1:length(AuxFields)
                ixGood=ixGood & ~isnan(MetricsEach{index}.(AuxFields{mndex}));
            end
            for mndex=1:length(AuxFields)
                AuxMetrics.(AuxFields{mndex})=[AuxMetrics.(AuxFields{mndex});MetricsEach{index}.(AuxFields{mndex})(ixGood)];
            end
            AuxGold=[AuxGold;GoldEach{index}(ixGood)];
        end
        verbose([char(9) char(9) 'Select all non-NaN samples in all metrics used ... done'],ShowMsgs);
        
        verbose([char(9) char(9) 'Estimating thresholds ...'],ShowMsgs);
        %PAU
        mystate='PAU';
        mymetric='resppwr_RCGxxx_win2sid';
%         mymetric='varnorm_RCGxxx_win2sid';
        auxMetric=AuxMetrics.(mymetric);
        cens=min(auxMetric):0.0001:max(auxMetric);
        pdfH1=hist(auxMetric(AuxGold==stateCode(mystate)),cens);
        pdfH0=hist(auxMetric(AuxGold==stateCode('SYB')),cens);
%         pdfH0=hist(auxMetric(AuxGold~=stateCode(mystate)),cens);
        pD=cumsum(pdfH1)./length(auxMetric(AuxGold==stateCode(mystate)));
        pFA=cumsum(pdfH0)./length(auxMetric(AuxGold==stateCode('SYB')));
%         pFA=cumsum(pdfH0)./length(auxMetric(AuxGold~=stateCode(mystate)));
        d=pD-pFA;
        [d_opt,ix_opt]=max(d);
        ClassificationParameters.(mystate).(mymetric).gamma=cens(ix_opt);
        ClassificationParameters.(mystate).(mymetric).d_opt=d_opt;
        ClassificationParameters.(mystate).(mymetric).pD_opt=pD(ix_opt);
        ClassificationParameters.(mystate).(mymetric).pFA_opt=pFA(ix_opt);
        
        mymetric='resppwr_ABDxxx_win2sid';
%         mymetric='varnorm_ABDxxx_win2sid';
        auxMetric=AuxMetrics.(mymetric);
        cens=min(auxMetric):0.0001:max(auxMetric);
        pdfH1=hist(auxMetric(AuxGold==stateCode(mystate)),cens);
        pdfH0=hist(auxMetric(AuxGold==stateCode('SYB')),cens);
%         pdfH0=hist(auxMetric(AuxGold~=stateCode(mystate)),cens);
        pD=cumsum(pdfH1)./length(auxMetric(AuxGold==stateCode(mystate)));
        pFA=cumsum(pdfH0)./length(auxMetric(AuxGold==stateCode('SYB')));
%         pFA=cumsum(pdfH0)./length(auxMetric(AuxGold~=stateCode(mystate)));
        d=pD-pFA;
        [d_opt,ix_opt]=max(d);
        ClassificationParameters.(mystate).(mymetric).gamma=cens(ix_opt);
        ClassificationParameters.(mystate).(mymetric).d_opt=d_opt;
        ClassificationParameters.(mystate).(mymetric).pD_opt=pD(ix_opt);
        ClassificationParameters.(mystate).(mymetric).pFA_opt=pFA(ix_opt);
        
        %MVT
        mystate='MVT';
        mymetric='br2mvpw_RCGxxx_filtbnk';
%         mymetric='nppnorm_RCGxxx_win2sid';
        auxMetric=AuxMetrics.(mymetric);
        cens=min(auxMetric):0.0001:max(auxMetric);
        pdfH1=hist(auxMetric(AuxGold==stateCode(mystate)),cens);
        pdfH0=hist(auxMetric(AuxGold==stateCode('SYB')),cens);
%         pdfH0=hist(auxMetric(AuxGold~=stateCode(mystate)),cens);
        pD=cumsum(pdfH1)./length(auxMetric(AuxGold==stateCode(mystate)));
        pFA=cumsum(pdfH0)./length(auxMetric(AuxGold==stateCode('SYB')));
%         pFA=cumsum(pdfH0)./length(auxMetric(AuxGold~=stateCode(mystate)));
        d=pD-pFA;
        [d_opt,ix_opt]=max(d);
%         [d_opt,ix_opt]=max(abs(d));
        ClassificationParameters.(mystate).(mymetric).gamma=cens(ix_opt);
        ClassificationParameters.(mystate).(mymetric).d_opt=d_opt;
        ClassificationParameters.(mystate).(mymetric).pD_opt=pD(ix_opt);
        ClassificationParameters.(mystate).(mymetric).pFA_opt=pFA(ix_opt);
        
        mymetric='br2mvpw_ABDxxx_filtbnk';
%         mymetric='nppnorm_ABDxxx_win2sid';
        auxMetric=AuxMetrics.(mymetric);
        cens=min(auxMetric):0.0001:max(auxMetric);
        pdfH1=hist(auxMetric(AuxGold==stateCode(mystate)),cens);
        pdfH0=hist(auxMetric(AuxGold==stateCode('SYB')),cens);
%         pdfH0=hist(auxMetric(AuxGold~=stateCode(mystate)),cens);
        pD=cumsum(pdfH1)./length(auxMetric(AuxGold==stateCode(mystate)));
        pFA=cumsum(pdfH0)./length(auxMetric(AuxGold==stateCode('SYB')));
%         pFA=cumsum(pdfH0)./length(auxMetric(AuxGold~=stateCode(mystate)));
        d=pD-pFA;
        [d_opt,ix_opt]=max(d);
%         [d_opt,ix_opt]=max(abs(d));
        ClassificationParameters.(mystate).(mymetric).gamma=cens(ix_opt);
        ClassificationParameters.(mystate).(mymetric).d_opt=d_opt;
        ClassificationParameters.(mystate).(mymetric).pD_opt=pD(ix_opt);
        ClassificationParameters.(mystate).(mymetric).pFA_opt=pFA(ix_opt);
        
        %ASB
        mystate='ASB';
        mymetric='taphase_RCGABD_bpbinsg';
%         mymetric='difbrea_RCGABD_dtbinsg';
        auxMetric=AuxMetrics.(mymetric);
        cens=min(auxMetric):0.0001:max(auxMetric);
        pdfH1=hist(auxMetric(AuxGold==stateCode(mystate)),cens);
        pdfH0=hist(auxMetric(AuxGold==stateCode('SYB')),cens);
%         pdfH0=hist(auxMetric(AuxGold~=stateCode(mystate)),cens);
        pD=1-cumsum(pdfH1)./length(auxMetric(AuxGold==stateCode(mystate)));
        pFA=1-cumsum(pdfH0)./length(auxMetric(AuxGold==stateCode('SYB')));
%         pFA=1-cumsum(pdfH0)./length(auxMetric(AuxGold~=stateCode(mystate)));
        d=pD-pFA;
        [d_opt,ix_opt]=max(d);
        ClassificationParameters.(mystate).(mymetric).gamma=cens(ix_opt);
        ClassificationParameters.(mystate).(mymetric).d_opt=d_opt;
        ClassificationParameters.(mystate).(mymetric).pD_opt=pD(ix_opt);
        ClassificationParameters.(mystate).(mymetric).pFA_opt=pFA(ix_opt);
        
        verbose([char(9) char(9) 'Estimating thresholds ... done'],ShowMsgs);

        clear AuxMetrics AuxGold AuxFields ixGood auxMetric mymetric mystate cens pdfH1 pdfH0 pD pFA d
        
        verbose([char(9) 'Training (obtain thresholds) ... done'],ShowMsgs);
    end

%% Classification
    verbose([char(9) 'Classifying based on ClassificationParameters ...'],ShowMsgs);
    RespiratoryState={};
    for index=1:numFiles
        AuxMetrics={};
        AuxFields={'resppwr_RCGxxx_win2sid';'resppwr_ABDxxx_win2sid';'br2mvpw_RCGxxx_filtbnk';'br2mvpw_ABDxxx_filtbnk';'taphase_RCGABD_bpbinsg'};
%         AuxFields={'varnorm_RCGxxx_win2sid';'varnorm_ABDxxx_win2sid';'nppnorm_RCGxxx_win2sid';'nppnorm_ABDxxx_win2sid';'difbrea_RCGABD_dtbinsg'};
        for mndex=1:length(AuxFields)
            AuxMetrics=setfield(AuxMetrics,AuxFields{mndex},[]);
        end
        ixGood=ones(lengthEach(index),1);
        for mndex=1:length(AuxFields)
            ixGood=ixGood & ~isnan(MetricsEach{index}.(AuxFields{mndex}));
        end
        for mndex=1:length(AuxFields)
            AuxMetrics.(AuxFields{mndex})=MetricsEach{index}.(AuxFields{mndex})(ixGood);
        end
        
        %Initialize aux scores
        AU_scores=zeros(length(AuxMetrics.(AuxFields{1})),1);
        
        %Evaluate thresholds
        %PAU
        AU_scores(and(AU_scores==0,and(AuxMetrics.resppwr_RCGxxx_win2sid <= ClassificationParameters.PAU.resppwr_RCGxxx_win2sid.gamma,AuxMetrics.resppwr_ABDxxx_win2sid <= ClassificationParameters.PAU.resppwr_ABDxxx_win2sid.gamma)))=stateCode('PAU');
%         AU_scores(and(AU_scores==0,and(AuxMetrics.varnorm_RCGxxx_win2sid <= ClassificationParameters.PAU.varnorm_RCGxxx_win2sid.gamma,AuxMetrics.varnorm_ABDxxx_win2sid <= ClassificationParameters.PAU.varnorm_ABDxxx_win2sid.gamma)))=stateCode('PAU');
        
        %MVT
        AU_scores(and(AU_scores==0,and(AuxMetrics.br2mvpw_RCGxxx_filtbnk <= ClassificationParameters.MVT.br2mvpw_RCGxxx_filtbnk.gamma,AuxMetrics.br2mvpw_ABDxxx_filtbnk <= ClassificationParameters.MVT.br2mvpw_ABDxxx_filtbnk.gamma)))=stateCode('MVT');
%         AU_scores(and(AU_scores==0,and(AuxMetrics.nppnorm_RCGxxx_win2sid >= ClassificationParameters.MVT.nppnorm_RCGxxx_win2sid.gamma,AuxMetrics.nppnorm_ABDxxx_win2sid >= ClassificationParameters.MVT.nppnorm_ABDxxx_win2sid.gamma)))=stateCode('MVT');
        
        %ASB
        AU_scores(and(AU_scores==0,AuxMetrics.taphase_RCGABD_bpbinsg >= ClassificationParameters.ASB.taphase_RCGABD_bpbinsg.gamma))=stateCode('ASB');
%         AU_scores(and(AU_scores==0,AuxMetrics.difbrea_RCGABD_dtbinsg >= ClassificationParameters.ASB.difbrea_RCGABD_dtbinsg.gamma))=stateCode('ASB');
        
        %SYB
        AU_scores(AU_scores==0)=stateCode('SYB');

        %Assign the corresponding respiratory state to each sample
        RespiratoryState{index}=zeros(lengthEach(index),1);
        RespiratoryState{index}(ixGood)=AU_scores;
        
        clear AuxMetrics AuxFields ixGood AU_scores
        
        verbose([char(9) char(9) 'subject ' num2str(index) ' ... done'],ShowMsgs);
    end
    verbose([char(9) 'Classifying based on ClassificationParameters ... done'],ShowMsgs);
    verbose([mfilename ': end'],ShowMsgs);
end