function [respatt_RCGABD_prelAUR,PatternCodes,ClassificationParameters] = resPatt_preAUREA(MetricsEach,ClassificationParameters,ShowMsgs)
%RESPATT_PREAUREA Estimates the instantaneous  respiratory pattern using the  original AUREA algorithm
%   [respatt_RCGABD_prelAUR,PatternCodes,ClassificationParameters] = resPatt_preAUREA(MetricsEach,ClassificationParameters,ShowMsgs)
%       estimates the respiratory pattern using the
%       original AUREA algorithm described in [1].
%
%   INPUT
%   MetricsEach is a 1-by-K struct array containing
%       the struct array Metrics (output from CardiorespiratoryMetrics)
%       for each of the K records under analysis.
%   ClassificationParameters is a struct array
%       as output by resPatt_preAUREA.
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output.
%
%   OUTPUT
%   respatt_RCGABD_prelAUR is a 1-by-K struct array with
%       the respiratory pattern classification for
%       each of the K records under analysis.
%       Each cell is a vector with the classification
%       values.
%   PatternCodes is an struct array with the numerical
%       code for each of the respiratory patterns
%       in respatt_RCGABD_prelAUR.
%   ClassificationParameters is a struct array
%       with the classification parameters after
%       training with InputData.
%
%   EXAMPLE
%   %For training   
%   [~,~,ClassificationParameters]=resPatt_preAUREA(MetricsEach,[],ShowMsgs);
%   %For testing
%   [respatt_RCGABD_prelAUR,PatternCodes]=resPatt_preAUREA(MetricsEach,ClassificationParameters,ShowMsgs);
%
%   VERSION HISTORY
%   2014_01_13 - Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Proc. 33rd IEEE Ann. Int. Conf. Eng. Med. Biol. Soc.,
%       Boston, USA, 2011, pp. 3201-3204.
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

    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    PatternCodes.PAU=1;
    PatternCodes.ASB=2;
    PatternCodes.MVT=3;
    PatternCodes.SYB=4;
    PatternCodes.SIH=5;
    PatternCodes.BRE=6;
    PatternCodes.UNK=99;

    numFiles=length(MetricsEach);
    lengthEach=zeros(numFiles,1);
    inputMetrics=fields(MetricsEach{1});
    parfor index=1:numFiles
        lengthEach(index)=length(MetricsEach{index}.(inputMetrics{1}));
    end
    clear inputMetrics

%% Training
    if ~exist('ClassificationParameters') | isempty(ClassificationParameters)
        ClassificationParameters.Algorithm=mfilename;

        %Select features to use
        features=[];
        for index=1:numFiles
            features=[features;MetricsEach{index}.resppwr_RCGxxx_win2sid MetricsEach{index}.resppwr_ABDxxx_win2sid MetricsEach{index}.br2mvpw_RCGxxx_filtbnk MetricsEach{index}.br2mvpw_ABDxxx_filtbnk MetricsEach{index}.taphase_RCGABD_bpbinsg MetricsEach{index}.rootmsq_RCGABD_win2sid];
        end
        ixGood=~isnan(sum(features,2));
        features=features(ixGood,:);
        prc=features(:,1);
        pab=features(:,2);
        mrc=features(:,3);
        mab=features(:,4);
        phi=features(:,5);
        rms=features(:,6);
        clear features

        %Clustering
        %PAU
        startPointP=[log(0.1),log(0.1),0,0,log(0.1);
            0,0,0,0,log(0.1);
            0,0,-1,-1,1;
            0,0,1,1,log(0.1)];
        features=[log(prc) log(pab) mrc mab log(rms)];
        [IDXp,Cp]=kmeans(features,4,'options',statset('MaxIter',150),'start',startPointP);
        w1PM=mean(IDXp==PatternCodes.PAU)/(mean(IDXp==PatternCodes.MVT)+mean(IDXp==PatternCodes.PAU));
        w1PA=mean(IDXp==PatternCodes.PAU)/(mean(IDXp==PatternCodes.ASB)+mean(IDXp==PatternCodes.PAU));
        w1PQ=mean(IDXp==PatternCodes.PAU)/(mean(IDXp==PatternCodes.SYB)+mean(IDXp==PatternCodes.PAU));
        gammaPM=(Cp(PatternCodes.MVT,:)-Cp(PatternCodes.PAU,:)).*w1PM+Cp(PatternCodes.PAU,:);
        gammaPA=(Cp(PatternCodes.ASB,:)-Cp(PatternCodes.PAU,:)).*w1PA+Cp(PatternCodes.PAU,:);
        gammaPQ=(Cp(PatternCodes.SYB,:)-Cp(PatternCodes.PAU,:)).*w1PQ+Cp(PatternCodes.PAU,:);
        
        ClassificationParameters.gammaPM=gammaPM;
        ClassificationParameters.gammaPA=gammaPA;
        ClassificationParameters.gammaPQ=gammaPQ;
        ClassificationParameters.Cp=Cp;

        distPM=(features-ones(length(features),1)*ClassificationParameters.gammaPM)*(ClassificationParameters.Cp(PatternCodes.MVT,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        distPA=(features-ones(length(features),1)*ClassificationParameters.gammaPA)*(ClassificationParameters.Cp(PatternCodes.ASB,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        distPQ=(features-ones(length(features),1)*ClassificationParameters.gammaPQ)*(ClassificationParameters.Cp(PatternCodes.SYB,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        IDXp(and(distPM<0,and(distPA<0,distPQ<0)))=PatternCodes.PAU;
        IDXp(not(and(distPM<0,and(distPA<0,distPQ<0))))=0;
        
        %MVT
        startPointM=[0,0,-1,-1,1;
            0,0,1,1,log(0.1)];
        features=[log(prc(IDXp~=1)) log(pab(IDXp~=1)) mrc(IDXp~=1) mab(IDXp~=1) log(rms(IDXp~=1))];
        iBreath=2;
        iEvent=1;
        [IDXm,Cm]=kmeans(features,2,'options',statset('MaxIter',150),'start',startPointM);
        w1M=mean(IDXm==iEvent);
        gammaWM=((Cm(iBreath,:)-Cm(iEvent,:)).*w1M+Cm(iEvent,:));
        
        ClassificationParameters.gammaWM=gammaWM;
        ClassificationParameters.Cm=Cm;
        
        distM=(features-ones(length(features),1)*ClassificationParameters.gammaWM)*(ClassificationParameters.Cm(iBreath,:)-ClassificationParameters.Cm(iEvent,:))';
        
        %ASB
        startPointA=[0;1];
        features=phi(IDXp~=1);
        features=features(distM>=0);
        iBreath=1;
        iEvent=2;
        [IDXa,Ca]=kmeans(features,2,'options',statset('MaxIter',150),'start',startPointA);
        w1Q=mean(IDXa==iBreath);
        gammaWA=((Ca(iEvent,:)-Ca(iBreath,:)).*w1Q+Ca(iBreath,:));
        
        ClassificationParameters.gammaWA=gammaWA;
        ClassificationParameters.Ca=Ca;

        clear prc pab mrc mab phi rms IDXp IDXm IDXa gammaPM gammaPA gammaPQ Cp gammaWM Cm gammaWA Ca distPM distPA distPQ distM distA
    end

%% Classification
    respatt_RCGABD_prelAUR={};
    for index=1:numFiles
        %Select the metrics to be used
        features=[MetricsEach{index}.resppwr_RCGxxx_win2sid MetricsEach{index}.resppwr_ABDxxx_win2sid MetricsEach{index}.br2mvpw_RCGxxx_filtbnk MetricsEach{index}.br2mvpw_ABDxxx_filtbnk MetricsEach{index}.taphase_RCGABD_bpbinsg MetricsEach{index}.rootmsq_RCGABD_win2sid];
        ixGood=~isnan(sum(features,2));
        features=features(ixGood,:);
        prc=features(:,1);
        pab=features(:,2);
        mrc=features(:,3);
        mab=features(:,4);
        phi=features(:,5);
        rms=features(:,6);
        clear features

        %Evaluate Cluster Thresholds
        %PAU
        features=[log(prc) log(pab) mrc mab log(rms)];
        distPM=(features-ones(length(features),1)*ClassificationParameters.gammaPM)*(ClassificationParameters.Cp(PatternCodes.MVT,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        distPA=(features-ones(length(features),1)*ClassificationParameters.gammaPA)*(ClassificationParameters.Cp(PatternCodes.ASB,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        distPQ=(features-ones(length(features),1)*ClassificationParameters.gammaPQ)*(ClassificationParameters.Cp(PatternCodes.SYB,:)-ClassificationParameters.Cp(PatternCodes.PAU,:))';
        IDXp=zeros(size(prc));
        IDXp(and(distPM<0,and(distPA<0,distPQ<0)))=PatternCodes.PAU;
        IDXp(not(and(distPM<0,and(distPA<0,distPQ<0))))=0;
        
        %MVT
        features=[log(prc(IDXp~=1)) log(pab(IDXp~=1)) mrc(IDXp~=1) mab(IDXp~=1) log(rms(IDXp~=1))];
        iBreath=2;
        iEvent=1;
        distM=(features-ones(length(features),1)*ClassificationParameters.gammaWM)*(ClassificationParameters.Cm(iBreath,:)-ClassificationParameters.Cm(iEvent,:))';
        
        %ASB
        features=phi(IDXp~=1);
        features=features(distM>=0);
        iBreath=1;
        iEvent=2;
        distA=(features-ones(length(features),1)*ClassificationParameters.gammaWA)*(ClassificationParameters.Ca(iEvent,:)-ClassificationParameters.Ca(iBreath,:))';
        
        AU_scores=zeros(length(prc),1);
        AU_scores(IDXp==1)=PatternCodes.PAU;
        indexEvents2=find(IDXp~=1);
        AU_scores(indexEvents2(distM<0))=PatternCodes.MVT;
        indexEvents3=indexEvents2(distM>=0);
        AU_scores(indexEvents3(distA<=0))=PatternCodes.SYB;
        AU_scores(indexEvents3(distA>0))=PatternCodes.ASB;
        
        respatt_RCGABD_prelAUR{index}=zeros(lengthEach(index),1);
        respatt_RCGABD_prelAUR{index}(ixGood)=AU_scores;
        
        clear prc pab mrc mab phi rms IDXp distPM distPA distPQ distM distA AU_scores indexEvents2 indexEvents3 ixGood features
    end
end