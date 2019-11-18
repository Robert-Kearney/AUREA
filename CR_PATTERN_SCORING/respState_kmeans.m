function [RespiratoryState,StateCodes,ClassificationParameters] = respState_kmeans(MetricsEach,Outlier_DetectionParam,StateOrder,WhichMetrics,MetricInitialization,MinStateLength,ClassificationParameters,ShowMsgs)
%AUREASTATECLASSIFICATION Estimates the instantaneous respiratory state.
%   [RespiratoryState,StateCodes,ClassificationParameters] = aureaStateClassification(MetricsEach,Outlier_DetectionParam,StateOrder,WhichMetrics,MetricInitialization,MinStateLength,ClassificationParameters,ShowMsgs)
%       estimates AUREA's respiratory state using
%       the input metrics.
%
%   INPUT
%   MetricsEach is a 1-by-K struct array containing
%       the struct array Metrics (output from CardiorespiratoryMetrics)
%       for each of the K records under analysis.
%   Outlier_DetectionParam is a struct array containing
%       the parameters for outlier identification.
%   StateOrder is a 1-by-S struct array containing
%       the order in which the states will be
%       classified (default={'PAU','MVT','SYB','ASB'}).
%   WhichMetrics is a struct array indicating the
%       metrics that will be used to custer the
%       respiratory state. Default:
%           WhichMetrics={'varnorm_RCGxxx_win2sid';
%                       'varnorm_ABDxxx_win2sid';
%                       'nppnorm_RCGxxx_win2sid';
%                       'nppnorm_ABDxxx_win2sid';
%                       'sumbrea_RCGABD_dtbinsg';
%                       'difbrea_RCGABD_dtbinsg'};
%   MetricInitialization is a struct array indicating
%       the initialization flag for the State centroid
%       for each of the metrics in WhichMetrics. A value
%       of +1 will initialize the cluster centroid to
%       the maximum value of the metric, and a value of
%       -1 to the minimum. Default:
%           MetricInitialization.PAU=[-1,-1,-1,-1,-1,-1];
%           MetricInitialization.MVT=[1,1,1,1,-1,-1];
%           MetricInitialization.SYB=[1,1,-1,-1,1,-1];
%           MetricInitialization.ASB=[1,1,-1,-1,-1,1];
%       With the default values in WhichMetrics and
%       MetricInitialization, the PAU centroid will be
%       initialized to [min(varnorm_RCGxxx_win2sid) min(varnorm_ABDxxx_win2sid) min(nppnorm_RCGxxx_win2sid) min(nppnorm_ABDxxx_win2sid) min(sumbrea_RCGABD_dtbinsg) min(difbrea_RCGABD_dtbinsg)].
%   MinStateLength is a scalar with the minimum
%       state length in samples (default=25).
%   ClassificationParameters is a struct array
%       as output by respState_kmeans.
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
%       training with InputData.
%
%   EXAMPLE
%   %For training   
%   [~,~,ClassificationParameters]=respState_kmeans(MetricsEach,Outlier_DetectionParam);
%   %For testing
%   [RespiratoryState,StateCodes]=respState_kmeans(MetricsEach,[],[],[],[],[],ClassificationParameters);
%
%   VERSION HISTORY
%   2016_04_09 - Deprecated the function (CARR).
%   2014_01_09 - Renamed function and added function to detect outliers (CARR).
%   2013_11_24 - Created by Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Proc. 33rd IEEE Ann. Int. Conf. Eng. Med. Biol. Soc.,
%       Boston, USA, 2011, pp. 3201-3204.
%
%
%Copyright (c) 2012-2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    deprecate({'resPatt_kmeans'});

    if ~exist('Outlier_DetectionParam') | isempty(Outlier_DetectionParam)
        Outlier_DetectionParam.alphaMetrics=0.001;
        Outlier_DetectionParam.alphaCluster=0.001;
    end
    if ~exist('StateOrder') | isempty(StateOrder)
        StateOrder={'PAU','MVT','SYB','ASB'};
    end 
    if ~exist('WhichMetrics') | isempty(WhichMetrics)
        WhichMetrics={'varnorm_RCGxxx_win2sid';'varnorm_ABDxxx_win2sid';'nppnorm_RCGxxx_win2sid';'nppnorm_ABDxxx_win2sid';'sumbrea_RCGABD_dtbinsg';'difbrea_RCGABD_dtbinsg'};
    end
    if ~exist('MetricInitialization') | isempty(MetricInitialization)
        MetricInitialization.PAU=[-1,-1,-1,-1,-1,-1];
        MetricInitialization.MVT=[1,1,1,1,-1,-1];
        MetricInitialization.SYB=[1,1,-1,-1,1,-1];
        MetricInitialization.ASB=[1,1,-1,-1,-1,1];
    end
    if ~exist('MinStateLength') | isempty(MinStateLength)
        MinStateLength=25;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    StateCodes.PAU=1;
    StateCodes.ASB=2;
    StateCodes.MVT=3;
    StateCodes.SYB=4;
    StateCodes.SIH=5;
    StateCodes.BRE=6;
    StateCodes.UNK=99;
    
    numFiles=length(MetricsEach);
    lengthEach=zeros(numFiles,1);
    for index=1:numFiles
        lengthEach(index)=length(MetricsEach{index}.(WhichMetrics{1}));
    end

%% Training
    if ~exist('ClassificationParameters') | isempty(ClassificationParameters)
        verbose(['Training (obtain cluster parameters)...'],ShowMsgs);
        
        StateOrderedCodes=[];
        for index=1:length(StateOrder)
            StateOrderedCodes=[StateOrderedCodes;StateCodes.(StateOrder{index})];
        end
        
        ClassificationParameters.StateOrder=StateOrder;
        ClassificationParameters.MinStateLength=MinStateLength;
        ClassificationParameters.StateOrderedCodes=StateOrderedCodes;
        ClassificationParameters.WhichMetrics=WhichMetrics;

        AuxMetrics={};
        for mndex=1:length(WhichMetrics)
            AuxMetrics=setfield(AuxMetrics,WhichMetrics{mndex},[]);
        end
        AuxFields=fields(AuxMetrics);
        for index=1:numFiles
            ixGood=ones(lengthEach(index),1);
            for mndex=1:length(fields(AuxMetrics))
                ixGood=ixGood & ~isnan(MetricsEach{index}.(AuxFields{mndex}));
            end
            for mndex=1:length(fields(AuxMetrics))
                AuxMetrics.(AuxFields{mndex})=[AuxMetrics.(AuxFields{mndex});MetricsEach{index}.(AuxFields{mndex})(ixGood)];
            end
        end

        %Select features to use
        strFeats='[';
        for jndex=1:length(WhichMetrics)
            strFeats=[strFeats 'AuxMetrics.' WhichMetrics{jndex} ' '];
        end
        strFeats=[strFeats(1:end-1) ']'];
        features=eval(strFeats);
        
        %Initialize aux scores
        AU_scores=zeros(size(features,1),1);
        
        %Detect outliers
        [Outliers,OutlierMetadata]=detectMetricOutliers(AuxMetrics,Outlier_DetectionParam,[],ShowMsgs);
        AU_scores(Outliers==1)=StateCodes.UNK;
        ClassificationParameters.OutlierMetadata=OutlierMetadata;
        clear Outliers OutlierMetadata
        verbose([char(9) 'setting metric outliers to UNK ... done'],ShowMsgs);

        %Median and quantiles of metrics
        ClassificationParameters.metricMedian=ClassificationParameters.OutlierMetadata.median;
        ClassificationParameters.metricIQR=ClassificationParameters.OutlierMetadata.iqr;
        verbose([char(9) 'metric median and iqr ... done'],ShowMsgs);
        
        %Rescale features and do PCA
        features=features(AU_scores==0,:);
        features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian)./(ones(size(features,1),1)*ClassificationParameters.metricIQR);
        % [coeff,features,latent]=pca(features);
        verbose([char(9) 'rescaling metrics ... done'],ShowMsgs);
        
        %Set starting points for each cluster
        strStartPoint='[';
        for index=1:length(StateOrder)
            for jndex=1:length(WhichMetrics)
                if MetricInitialization.(StateOrder{index})(jndex)==-1
                    myStart='min';
                elseif MetricInitialization.(StateOrder{index})(jndex)==1
                    myStart='max';
                else
                    display(['Error in cluster initialization']);
                    return;
                end
                strStartPoint=[strStartPoint myStart '(features(:,' num2str(jndex) ')) '];
            end
            strStartPoint=[strStartPoint(1:end-1) ';'];
        end
        strStartPoint=[strStartPoint(1:end-1) '];'];
        startPoint=eval(strStartPoint);
        verbose([char(9) 'initialize cluster centroids ... done'],ShowMsgs);
        
        % Clustering
        [IDX,Centroids]=kmeans(features,length(StateOrder),'options',statset('MaxIter',1000),'start',startPoint);
        verbose([char(9) 'clustering ... done'],ShowMsgs);
        
        for index=1:length(StateOrder)
            ClassificationParameters.Centroids.(StateOrder{index})=Centroids(index,:);
        end
        verbose([char(9) 'clustering ... done'],ShowMsgs);
        
        clear features auxqtl AU_scores AuxMetrics AuxFields IDX Centroids w1ST_RE gammaST_RE ST RE startPoint strStartPoint
        verbose([char(9) 'Training ... done'],ShowMsgs);
    end

%% Classification
    verbose(['Classifying Respiratory State...'],ShowMsgs);
    RespiratoryState={};
    for index=1:numFiles
        verbose([char(9) 'subject: ' num2str(index)],ShowMsgs);

        %Select features to use
        strFeats='[';
        for jndex=1:length(ClassificationParameters.WhichMetrics)
            strFeats=[strFeats 'MetricsEach{index}.' ClassificationParameters.WhichMetrics{jndex} ' '];
        end
        strFeats=[strFeats(1:end-1) ']'];
        features=eval(strFeats);
        features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian)./(ones(size(features,1),1)*ClassificationParameters.metricIQR);
        verbose([char(9) char(9) 'selecting and scaling features ... done'],ShowMsgs);
        
        %Evaluate Cluster Thresholds
        Distance=ones(size(features,1),length(ClassificationParameters.StateOrder)).*inf;
        for jndex=1:length(ClassificationParameters.StateOrder)
            Distance(:,jndex)=pdist2(features,ClassificationParameters.Centroids.(ClassificationParameters.StateOrder{jndex}),'euclidean');
        end
        [~,IDX]=min(Distance,[],2);
        AU_scores=ClassificationParameters.StateOrderedCodes(IDX);
        verbose([char(9) char(9) 'classifying respiratory state ... done'],ShowMsgs);
        
        %Detect Outliers
        Outliers=zeros(size(AU_scores));
        if isfield(ClassificationParameters.OutlierMetadata.DetectionParam,'alphaCluster')
            %Based on cluster distance quantile
            for jndex=1:length(ClassificationParameters.StateOrder)
                thisSttCode=StateCodes.(ClassificationParameters.StateOrder{jndex});
                ixThisStt=find(AU_scores==thisSttCode);
                auxDist=Distance(ixThisStt,thisSttCode);
                auxGammaOutl=quantile(auxDist,1-ClassificationParameters.OutlierMetadata.DetectionParam.alphaCluster);
                Outliers(ixThisStt(auxDist>auxGammaOutl))=1;
                clear thisSttCode ixThisStt auxDist auxGammaOutl
            end
        else
            %Based on metrics quantiles
            Outliers=detectMetricOutliers(MetricsEach{index},[],ClassificationParameters.OutlierMetadata,ShowMsgs);
        end
        AU_scores(Outliers==1)=StateCodes.UNK;
        verbose([char(9) char(9) 'setting outliers to UNK ... done'],ShowMsgs);

        %Average to set minStateLength
        ixGood=sum(isnan(features),2)==0;
        tmp_scores=AU_scores(ixGood);
        Tmp_scores=signal2events(tmp_scores);
        elen_scores=Tmp_scores(:,2)-Tmp_scores(:,1)+1;
        Tmp_scores(elen_scores<ClassificationParameters.MinStateLength,3)=0;
        tmp_scores=events2signal(Tmp_scores);
        Tmp_scores=signal2events(tmp_scores);
        AuxZeros=Tmp_scores(Tmp_scores(:,3)==0,:);
        tmp_scores=events2signal(Tmp_scores);
        for jndex=2:size(AuxZeros,1)
            prev=AuxZeros(jndex,1)-1;
            next=AuxZeros(jndex,2)+1;
            if (next>sum(ixGood))
                next=sum(ixGood);
            end
            midp=floor((prev+next)/2);
            tmp_scores(prev+1:midp)=tmp_scores(prev);
            tmp_scores(midp+1:next)=tmp_scores(next);
        end

        AU_scores(ixGood)=tmp_scores;
        AU_scores(~ixGood)=0;
        verbose([char(9) char(9) 'setting MinStateLength ... done'],ShowMsgs);

        RespiratoryState{index}=AU_scores;
        
        clear AU_scores features ixGood
    end
    verbose([char(9) 'Classifying Respiratory State... done'],ShowMsgs);
end