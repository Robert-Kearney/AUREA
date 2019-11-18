function [respatt_RCGABD_ubadjkm,PatternCodes,ClassificationParameters] = resPatt_ubAdjKmeans(MetricsEach,Outlier_DetectionParam,PattOrder,WhichMetrics,MetricInitialization,MinPattLength,ClassificationParameters,ShowMsgs)
%RESPATT_UBADJKMEANS Estimates the instantaneous respiratory pattern using adjusted kmeans
%   [respatt_RCGABD_ubadjkm,PatternCodes,ClassificationParameters] = resPatt_ubAdjKmeans(MetricsEach,Outlier_DetectionParam,PattOrder,WhichMetrics,MetricInitialization,MinPattLength,ClassificationParameters,ShowMsgs)
%       estimates AUREA's respiratory pattern using
%       the input metrics.
%
%   INPUT
%   MetricsEach is a 1-by-K struct array containing
%       the struct array Metrics (output from CardiorespiratoryMetrics)
%       for each of the K records under analysis.
%   Outlier_DetectionParam is a struct array containing
%       the parameters for outlier identification
%       as required by function detectMetricOutliers.
%   PattOrder is a 1-by-S struct array containing
%       the order in which the patterns will be
%       classified (default={'PAU','MVT','SYB','ASB'}).
%   WhichMetrics is a struct array indicating the
%       metrics that will be used to classify
%       each pattern. Default:
%           WhichMetrics.PAU={'varnorm_RCGxxx_win2sid','varnorm_ABDxxx_win2sid'};
%           WhichMetrics.MVT={'nppnorm_RCGxxx_win2sid','nppnorm_ABDxxx_win2sid'};
%           WhichMetrics.SYB={'sumbrea_RCGABD_dtbinsg'};
%           WhichMetrics.ASB={'difbrea_RCGABD_dtbinsg'};
%   MetricInitialization is a struct array indicating
%       the initialization flag for the Pattern centroid
%       for each of the metrics in WhichMetrics. A value
%       of +1 will initialize the cluster centroid to
%       the maximum value of the metric, and a value of
%       -1 to the minimum. Default:
%           MetricInitialization.PAU=[-1,-1];
%           MetricInitialization.MVT=[1,1];
%           MetricInitialization.SYB=[1];
%           MetricInitialization.ASB=[1];
%       With the default values in WhichMetrics and
%       MetricInitialization, the PAU centroid will be
%       initialized to [min(varnorm_RCGxxx_win2sid) min(varnorm_ABDxxx_win2sid)].
%   MinPattLength is a scalar with the minimum
%       pattern length in samples (default=25).
%   ClassificationParameters is a struct array
%       as output by resPatt_ubAdjKmeans.
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output.
%
%   OUTPUT
%   respatt_RCGABD_ubadjkm is a 1-by-K struct array with
%       the respiratory pattern classification for
%       each of the K records under analysis.
%       Each cell is a vector with the classification
%       values.
%   PatternCodes is an struct array with the numerical
%       code for each of the respiratory patterns
%       in respatt_RCGABD_ubadjkm.
%   ClassificationParameters is a struct array
%       with the classification parameters after
%       training with InputData.
%
%   EXAMPLE
%   %For training   
%   [~,~,ClassificationParameters]=resPatt_ubAdjKmeans(MetricsEach,Outlier_DetectionParam);
%   %For testing
%   [respatt_RCGABD_ubadjkm,PatternCodes]=resPatt_ubAdjKmeans(MetricsEach,[],[],[],[],[],ClassificationParameters);
%
%   VERSION HISTORY
%   2014_01_09 - Renamed function and added function to detect outliers (CARR).
%   2013_11_08 - Reestructured and separated Metric and CR Pattern computation (CARR).
%   2013_01_18 - Updated the NP stat and function structure (CARR).
%   2012_07_01 - Created by: Carlos A. Robles-Rubio.
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

    if ~exist('Outlier_DetectionParam') | isempty(Outlier_DetectionParam)
        Outlier_DetectionParam.alphaMetrics=0.001;
    end
    if ~exist('PattOrder') | isempty(PattOrder)
        PattOrder={'PAU','MVT','SYB','ASB'};
    end 
    if ~exist('WhichMetrics') | isempty(WhichMetrics)
        WhichMetrics.PAU={'varnorm_RCGxxx_win2sid','varnorm_ABDxxx_win2sid'};
        WhichMetrics.MVT={'nppnorm_RCGxxx_win2sid','nppnorm_ABDxxx_win2sid'};
        WhichMetrics.SYB={'sumbrea_RCGABD_dtbinsg'};
        WhichMetrics.ASB={'difbrea_RCGABD_dtbinsg'};
    end
    if ~exist('MetricInitialization') | isempty(MetricInitialization)
        MetricInitialization.PAU=[-1,-1];
        MetricInitialization.MVT=[1,1];
        MetricInitialization.SYB=[1];
        MetricInitialization.ASB=[1];
    end
    if ~exist('MinPattLength') | isempty(MinPattLength)
        MinPattLength=25;
    end
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
    parfor index=1:numFiles
        lengthEach(index)=length(MetricsEach{index}.(WhichMetrics.PAU{1}));
        
    end

%% Training
    if ~exist('ClassificationParameters') | isempty(ClassificationParameters)
        ClassificationParameters.PattOrder=PattOrder;
        ClassificationParameters.MinPattLength=MinPattLength;
        ClassificationParameters.WhichMetrics=WhichMetrics;

        AuxMetrics={};
        for sndex=1:length(PattOrder)
            for mndex=1:length(WhichMetrics.(PattOrder{sndex}))
                AuxMetrics=setfield(AuxMetrics,WhichMetrics.(PattOrder{sndex}){mndex},[]);
            end
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
        
        %Initialize aux scores
        AU_scores=zeros(size(AuxMetrics.(AuxFields{mndex})));
        
        % Detect outliers
        [Outliers,OutlierMetadata]=detectMetricOutliers(AuxMetrics,Outlier_DetectionParam,[],ShowMsgs);
        AU_scores(Outliers==1)=PatternCodes.UNK;
        ClassificationParameters.OutlierMetadata=OutlierMetadata;

        %Median and quantiles of metrics
        ClassificationParameters.metricMedian=ClassificationParameters.OutlierMetadata.median;
        ClassificationParameters.metricIQR=ClassificationParameters.OutlierMetadata.iqr;
        verbose([char(9) 'metric median and iqr ... done'],ShowMsgs);
        
        % Clustering
        for index=1:length(PattOrder)
            ST=1;
            RE=2;
            
            %Select features to use
            strFeats='[';
            for jndex=1:length(WhichMetrics.(PattOrder{index}))
                strFeats=[strFeats 'AuxMetrics.' WhichMetrics.(PattOrder{index}){jndex} '(AU_scores==0) '];
            end
            strFeats=[strFeats(1:end-1) ']'];
            features=eval(strFeats);
            
            %Standardize the features
            ixTheseMetrics=ismember(AuxFields,WhichMetrics.(PattOrder{index}));
            features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian(ixTheseMetrics))./(ones(size(features,1),1)*ClassificationParameters.metricIQR(ixTheseMetrics));
            verbose([char(9) 'rescaling metrics ... done'],ShowMsgs);
        
            %Set starting points for each cluster
            strStartPoint='[';
            for jndex=1:length(WhichMetrics.(PattOrder{index}))
                if MetricInitialization.(PattOrder{index})(jndex)==-1
                    myStart='min';
                elseif MetricInitialization.(PattOrder{index})(jndex)==1
                    myStart='max';
                else
                    display(['Error in cluster initialization']);
                    return;
                end
                strStartPoint=[strStartPoint myStart '(AuxMetrics.' WhichMetrics.(PattOrder{index}){jndex} '(AU_scores==0)) '];
            end
            strStartPoint=[strStartPoint(1:end-1) ';'];
            for jndex=1:length(WhichMetrics.(PattOrder{index}))
                if MetricInitialization.(PattOrder{index})(jndex)==-1
                    myStart='max';
                elseif MetricInitialization.(PattOrder{index})(jndex)==1
                    myStart='min';
                else
                    display(['Error in cluster initialization']);
                    return;
                end
                strStartPoint=[strStartPoint myStart '(AuxMetrics.' WhichMetrics.(PattOrder{index}){jndex} '(AU_scores==0)) '];
            end
            strStartPoint=[strStartPoint(1:end-1) ']'];
            startPoint=eval(strStartPoint);
            
            try
                [IDX,Centroids]=kmeans(features,2,'options',statset('MaxIter',10000),'start',startPoint);
                w1ST_RE=mean(IDX==ST)/(mean(IDX==RE)+mean(IDX==ST));
            catch ME
                warning(['Kmeans error when classifying ' PattOrder{index} ': ' ME.message]);
                if strcmp(ME.identifier,'stats:kmeans:TooManyClusters')
                    w1ST_RE=1;  %All remaining samples belong to this category
                    Centroids=nan(2,length(WhichMetrics.(PattOrder{index})));
                    Centroids(ST,:)=mean(features,1);
                    for jndex=1:size(Centroids,2)
                        if MetricInitialization.(PattOrder{index})(jndex)==1
                            Centroids(RE,jndex)=-inf;
                        else
                            Centroids(RE,jndex)=inf;
                        end
                    end
                end
            end
            gammaST_RE=(Centroids(RE,:)-Centroids(ST,:)).*w1ST_RE+Centroids(ST,:);
            distance=(features-ones(length(features),1)*gammaST_RE)*(Centroids(RE,:)-Centroids(ST,:))';
            indexEvents=find(AU_scores==0);
            AU_scores(indexEvents(distance<0))=PatternCodes.(PattOrder{index});
            
            ClassificationParameters.(PattOrder{index}).gammaST_RE=gammaST_RE;
            ClassificationParameters.(PattOrder{index}).ST=ST;
            ClassificationParameters.(PattOrder{index}).RE=RE;
            ClassificationParameters.(PattOrder{index}).Centroids=Centroids;
            ClassificationParameters.(PattOrder{index}).w1ST_RE=w1ST_RE;
        end
        
        clear AU_scores AuxMetrics AuxFields IDX Centroids w1ST_RE gammaST_RE ST RE Outliers OutlierMetadata
    end

%% Classification
    respatt_RCGABD_ubadjkm={};
    for index=1:numFiles
        %Initialize aux scores
        AU_scores=zeros(lengthEach(index),1);

        %Identify samples that are not NaN (ixGood) and create AuxMetrics
        AuxMetrics={};
        for sndex=1:length(ClassificationParameters.PattOrder)
            for mndex=1:length(ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{sndex}))
                AuxMetrics=setfield(AuxMetrics,ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{sndex}){mndex},[]);
            end
        end
        AuxFields=fields(AuxMetrics);
        ixGood=ones(lengthEach(index),1);
        for mndex=1:length(fields(AuxMetrics))
            ixGood=ixGood & ~isnan(MetricsEach{index}.(AuxFields{mndex}));
        end
        for mndex=1:length(fields(AuxMetrics))
            AuxMetrics.(AuxFields{mndex})=[AuxMetrics.(AuxFields{mndex});MetricsEach{index}.(AuxFields{mndex})(ixGood)];
        end
        clear sndex mndex

        %Evaluate Cluster Thresholds
        for jndex=1:length(ClassificationParameters.PattOrder)
            %Set the features to use
            %Each interation of the loop considers only  elements that have
            %not yet been assifned a pattern
          
            strFeats='[';
            curPattern=ClassificationParameters.PattOrder{jndex}
            for kndex=1:length(ClassificationParameters.WhichMetrics.(curPattern))
                strFeats=[strFeats 'MetricsEach{index}.' ClassificationParameters.WhichMetrics.(curPattern){kndex} '(AU_scores==0) '];
            end
            strFeats=[strFeats(1:end-1) ']'];
            features=eval(strFeats);
            
            %Standardize the features
            ixTheseMetrics=ismember(AuxFields,ClassificationParameters.WhichMetrics.(curPattern));
            features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian(ixTheseMetrics))./(ones(size(features,1),1)*ClassificationParameters.metricIQR(ixTheseMetrics));
            verbose([char(9) char(9) 'selecting and scaling features ... done'],ShowMsgs);
            curGAMMA=ClassificationParameters.(curPattern).gammaST_RE ;
            curRE=(ClassificationParameters.(curPattern).Centroids(ClassificationParameters.(curPattern).RE,:);
            curST=ClassificationParameters.(curPattern).Centroids(ClassificationParameters.(curPattern).ST,:);
            distance=(features-ones(length(features),1)*curGAMMA* curRE  - curST)';
            indexEvents=find(AU_scores==0);
            AU_scores(indexEvents(distance<0))=PatternCodes.(curPattern);
        end
        AU_scores(AU_scores==0)=PatternCodes.UNK;
        
        %Detect Outliers
        Outliers=zeros(size(AU_scores));
        if isfield(ClassificationParameters.OutlierMetadata.DetectionParam,'alphaCluster')
            %Based on cluster distance quantile
            for jndex=1:length(ClassificationParameters.PattOrder)
                thisPattCode=PatternCodes.(ClassificationParameters.PattOrder{jndex});
                ixThisPatt=find(AU_scores==thisPattCode);
                
                %Set the features to use
                strFeats='[';
                for kndex=1:length(ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}))
                    strFeats=[strFeats 'MetricsEach{index}.' ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}){kndex} '(ixThisPatt) '];
                end
                strFeats=[strFeats(1:end-1) ']'];
                features=eval(strFeats);
                %Standardize the features
                ixTheseMetrics=ismember(AuxFields,ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}));
                features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian(ixTheseMetrics))./(ones(size(features,1),1)*ClassificationParameters.metricIQR(ixTheseMetrics));
                verbose([char(9) char(9) 'selecting and scaling features ... done'],ShowMsgs);
                auxCentroid=median(features,1); %The median of each column

                auxDist=pdist2(features,auxCentroid);
                auxGammaOutl=quantile(auxDist,1-ClassificationParameters.OutlierMetadata.DetectionParam.alphaCluster,1);
                Outliers(ixThisPatt(auxDist>auxGammaOutl))=1;
                clear thisPattCode ixThisPatt auxDist auxGammaOutl
            end
        else
            %Based on metrics quantiles
            Outliers=detectMetricOutliers(AuxMetrics,[],ClassificationParameters.OutlierMetadata,ShowMsgs);
        end
        AU_scores(Outliers==1)=PatternCodes.UNK;
        verbose([char(9) char(9) 'setting outliers to UNK ... done'],ShowMsgs);

        %Perform time averaging for MinPattLength
        tmp_scores=AU_scores(ixGood);
        
        if length(tmp_scores)>0
            Tmp_scores=signal2events(tmp_scores);
        
            elen_scores=Tmp_scores(:,2)-Tmp_scores(:,1)+1;
            Tmp_scores(elen_scores<ClassificationParameters.MinPattLength,3)=0;
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
        else
            verbose([char(9) char(9) char(9) 'metrics of file ' num2str(index) ' were only NaNs'],ShowMsgs);
        end

        AU_scores(ixGood)=tmp_scores;
        AU_scores(~ixGood)=0;

        respatt_RCGABD_ubadjkm{index}=AU_scores;
    end
end