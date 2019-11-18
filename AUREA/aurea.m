classdef aurea  < matlab.System
    % AUREA - object oriented impementation of AUREA
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        comment char
        pattern = struct('whichPattern',' ','whichMetrics', {},'centroidInit', 0, ...
            'adjustedBoundary', 0, 'patternCID',1,'notPatternCID',2,'centroids',[],'patternFraction',[] );
        minPattLength double
        showMsgs logical
        outlierDetectionParam = struct('alphaMetrics',.001);
        featureSpaceDisplayFlag = false;
        version  ='V01.02'
        
        
    end
    
    methods
        function AU = aurea (inputArg1,inputArg2)
            % AUREA  Construct an instance of the AUREA Class
            %   Detailed explanation goes here
            AU.pattern(1,1).whichPattern='PAU';
            AU.pattern(2,1).whichPattern='MVT';
            AU.pattern(3,1).whichPattern='SYB';
            AU.pattern(4,1).whichPattern='ASB';
            
            AU.pattern(1,1).whichMetrics={'varnorm_RCGxxx_win2sid' ,'varnorm_ABDxxx_win2sid'};
            AU.pattern(2,1).whichMetrics={'nppnorm_RCGxxx_win2sid' 'nppnorm_ABDxxx_win2sid'};
            AU.pattern(3,1).whichMetrics={'sumbrea_RCGABD_dtbinsg'};
            AU.pattern(4,1).whichMetrics={'difbrea_RCGABD_dtbinsg'};
            
            AU.pattern(1,1).centroidInit={ 'min' 'min'};
            AU.pattern(2,1).centroidInit={'max' 'max'};
            AU.pattern(3,1).centroidInit={'max'};
            AU.pattern(4,1).centroidInit={'max'};
            AU.minPattLength=1;
            AU.showMsgs=true;
            
            
        end
        %%
        function dispf(AU)
            % Display full properties of the aurea object
            
            fNames=fieldnames(AU);
            for i=1:length(fNames),
                disp(AU.(fNames{i}));
            end
            nPattern=length(AU.pattern);
            for i=1:nPattern,
                disp(AU.pattern(i));
            end
        end
        %%
        function ACP = train(ATP,MetricsEach)
            % Train aurea 
            %   ACP - aurea object with classification infomration
            %   ATP - aurea object with training information
            %   MetricsEeach - cell array of metrics 
            disp('Train Aurea')
            %% Determine number of files and length
            numFiles=length(MetricsEach);
            lengthEach=zeros(numFiles,1);
            for index=1:numFiles
                lengthEach(index)=length(MetricsEach{index}.(ATP.pattern(1).whichMetrics{1}));
            end
            nPattern=length(ATP.pattern);
            
            
            
            ACP=ATP; % Inintialize the pit structure to contain  aurea classification parameters
            
            % Generate auxMetrics- an array of metrics concatonated from all
            % input files, discarding samples where any metrix is nan.
            
            % create the empty strucutre
            auxMetrics=[];
            for iPattern=1:nPattern
                for iMetric=1:length(ATP.pattern(iPattern).whichMetrics)
                    auxMetrics=setfield(auxMetrics,ATP.pattern(iPattern).whichMetrics{iMetric},[]);
                end
            end
            auxFields=fields(auxMetrics);
            nMetric=length(auxFields)
            for index=1:numFiles
                ixGood=ones(lengthEach(index),1);
                % Find samples in current file where any metric is a NaN
                for iMetric=1:nMetric
                    ixGood=ixGood & ~isnan(MetricsEach{index}.(auxFields{iMetric}));
                end
                % concatonate metrics for current file which are not NaNs.
                for iMetric=1:nMetric
                    auxMetrics.(auxFields{iMetric})=[auxMetrics.(auxFields{iMetric}) ; MetricsEach{index}.(auxFields{iMetric})(ixGood)];
                end
            end
            nSamp=length(auxMetrics.(auxFields{iMetric}));
            
            %Initialize auPatterns to UNASSIGNED
            auPatterns=categorical;
            auPatterns(1:nSamp,1)='UNASSIGNED';
            (zeros(nSamp,1));
            
            % Detect outliers and set them to UNK
            [Outliers,OutlierMetadata]=detectMetricOutliers(auxMetrics,ATP.outlierDetectionParam,[],ATP.showMsgs);
            auPatterns(Outliers==1)='UNK';
            
            
            % Store  Outlier metadata in ACP
            for iPattern=1:nPattern,
                nMetric=length(ATP.pattern(iPattern).whichMetrics);
                for iMetric=1:nMetric
                    jMetric=strfind((OutlierMetadata.WhichMetrics), ATP.pattern(iPattern).whichMetrics(iMetric));
                    kMetric=find(not(cellfun(@isempty,jMetric)));
                    ACP.pattern(iPattern).metricMedian(iMetric)=OutlierMetadata.median(kMetric);
                    ACP.pattern(iPattern).metricIQR(iMetric)=OutlierMetadata.iqr(kMetric);
                    ACP.pattern(iPattern).metricLowerQuantile(iMetric)=OutlierMetadata.lowerQuantile(kMetric);
                    ACP.pattern(iPattern).metricUpperQuantile(iMetric)=OutlierMetadata.upperQuantile(kMetric);
                end
            end
            
            verbose([char(9) 'metric median and iqr ... done'],ATP.showMsgs);
            
            % Clustering
            for iPattern=1:nPattern
                patternCID=1; % cluster ID for samples belonging to current pattern
                notPatternCID=2; % Cluster ID for samples NOT belong to current pattern
                curPattern=ACP.pattern(iPattern).whichPattern;
                disp(['Classifying:' curPattern])
                % Build feature set for current pattern
                nMetric=length(ATP.pattern(iPattern).whichMetrics);
                features=[];
                featureMax=[];
                featureMin=[];
                for iMetric=1:nMetric,
                    curMetric=ATP.pattern(iPattern).whichMetrics{iMetric};
                    indexEvents=find(auPatterns=='UNASSIGNED'); % Pointer to unassigned samples
                    features(:,iMetric)=auxMetrics.(curMetric)(indexEvents);
                    % Standardize feature by subtracting median and dividing by
                    % IQR
                    curMedian=ACP.pattern(iPattern).metricMedian(iMetric);
                    curIQR=ACP.pattern(iPattern).metricIQR(iMetric);
                    features(:,iMetric)=(features(:,iMetric)-curMedian)/curIQR;
                    featureMax=max(features);
                    featureMin=min(features);
                end
                %Set starting points for  cluster
                startPoint=[];
                for iMetric=1:nMetric,
                    curInit= ACP.pattern(iPattern).centroidInit{iMetric'};
                    if strcmp(curInit,'max')
                        startPoint(1,iMetric)=featureMax(iMetric);
                        startPoint(2,iMetric)=featureMin(iMetric);
                    elseif strcmp(curInit,'min')
                        startPoint(1,iMetric)=featureMin(iMetric);
                        startPoint(2,iMetric)=featureMax(iMetric);
                    else
                        error('invalid value for centroidInit');
                    end
                end
                
                
                try
                    % Train a kmeans classsifier
                    if gpuDeviceCount >0
                        featuresGPU=gpuArray(features); 
                        [IDX,Centroids]=kmeans(featuresGPU,2,'options',statset('MaxIter',100000),'start',startPoint);
                    else
                        [IDX,Centroids]=kmeans(features,2,'options',statset('MaxIter',100000),'start',startPoint);
                    end
                catch ME
                    warning(['Kmeans error when classifying ' curPattern ': ' ME.message]);
                    if strcmp(ME.identifier,'stats:kmeans:TooManyClusters')
                        w1ST_RE=1;  %All remaining samples belong to this category
                        Centroids=nan(2,length(WhichMetrics.(PattOrder{index})));
                        Centroids(patternCID,:)=mean(features,1);
                        for jndex=1:size(Centroids,2)
                            if MetricInitialization.(PattOrder{index})(jndex)==1
                                Centroids(RE,jndex)=-inf;
                            else
                                Centroids(RE,jndex)=inf;
                            end
                        end
                    end
                end
                % adjust boundaries based on number of samples in each custer
                % Equation 7.10 from Carlos thesis
                nPattern =mean(patternCID==IDX);
                nNotPattern = mean(IDX==notPatternCID);
                patternFraction= nPattern/(nPattern+nNotPattern); % Fraction of samples assigned to pattern clusters
                % Locate decision boundary at a fraction of the distance between
                % the two centroids in proportion to the relative number of samples in each pattern
                adjustedBoundary=(Centroids(notPatternCID,:)-Centroids(patternCID,:)).*patternFraction+Centroids(patternCID,:); % adjusted bounrary ??
                % Equation 7.11 from Carlos thesis
                % Determine distance of each feature from boundary. negative values
                % indicate it is coloser to the patternCluster and positive values
                % indicate it is closer to notPatternCluster
                distance=(features-ones(length(features),1)*adjustedBoundary)*(Centroids(notPatternCID,:)-Centroids(patternCID,:))';
                % samples with distance <0  are pattern #1
                auPatterns(indexEvents(distance<0))=curPattern;
                ACP.pattern(iPattern).adjustedBoundary=adjustedBoundary;   % Adjusted boundary
                ACP.pattern(iPattern).patternCID=patternCID;
                ACP.pattern(iPattern).notPatternCID=notPatternCID;
                ACP.pattern(iPattern).centroids=Centroids; % Centroids returned by kMeans
                ACP.pattern(iPattern).patternFraction=patternFraction; % Fraction of samples assigned to pattern
                if ATP.featureSpaceDisplayFlag,
                aureaPlotFeatureSpace(features, ACP.pattern(iPattern), distance,  iPattern, ACP.showMsgs);
                end
            end
            
        end
        %%
        
        function [ACP, pSeq]  = classify(ACP, metricsEach)
            % [ACP, pSeq]  = classify(ACP, metricsEach)
            % Classify samples based on metrics and the aurea classifer
            % ACP  - aurea classifcation object
            % pSeq - classified sequence
            % metricsEach - cell array of metrics 
            % Number of files and length of each
            disp('Outlier detection disabled');
            nFiles=length(metricsEach);
            lengthEach=zeros(nFiles,1);
            testMetric=ACP.pattern(1).whichMetrics{1};
            for iFile=1:nFiles
                lengthEach(iFile)=length(metricsEach{iFile}.(testMetric));
            end
            nPattern=length(ACP.pattern) ;
            %% Classification
            pSeq={};
            for iFile=1:nFiles
                curFile=metricsEach{iFile};
                %Initialize aux scores
                nSamp=lengthEach(iFile);
                auPattern=categorical();
                auPattern(1:nSamp,1)='UNASSIGNED';
                for iPattern=1:nPattern,
                    curPattern=ACP.pattern(iPattern).whichPattern;
                    nMetric=length(ACP.pattern(iPattern).whichMetrics);
                    
                    
                    %% Identify samples with NaNs in metrics
                    ixGood=ones(nSamp,1);
                    for iMetric=1:nMetric
                        curMetric=curFile.(ACP.pattern(iPattern).whichMetrics{iMetric});
                        ixGood=ixGood & ~isnan(curMetric);
                    end
                    % generate array of metrics for current pattern
                    auxMetrics=[];
                    for iMetric=1:nMetric,
                        curMetric=curFile.(ACP.pattern(iPattern).whichMetrics{iMetric});
                        auxMetrics(:,iMetric)=curMetric(ixGood);
                    end
                    
                    %% Evaluate Cluster Thresholds
                    %         for jndex=1:length(ClassificationParameters.PattOrder)
                    %Set the features to use
                    %Each interation of the loop considers only  elements that have
                    %not yet been assifned a pattern
                    % Find metrics for current pattern for samples which have not
                    % already been assugned to a pattern
                    % Get features for pattern
                    iUnassigned=find(auPattern=='UNASSIGNED');
                    features=[];
                    for iMetric=1:nMetric
                        curMetricName=ACP.pattern(iPattern).whichMetrics{iMetric};
                        curFeature=curFile.(curMetricName)(iUnassigned); % Get current feature
                        % Standardize
                        curFeature=(curFeature-ACP.pattern(iPattern).metricMedian(iMetric))./ACP.pattern(iPattern).metricIQR(iMetric);
                        features=cat(2,features,curFeature);
                    end
                    %% Assign  to current pattern
                    patternCID=ACP.pattern(iPattern).patternCID;
                    notPatternCID=ACP.pattern(iPattern).notPatternCID;
                    adjustedBoundary=ACP.pattern(iPattern).adjustedBoundary;
                    centroids=ACP.pattern(iPattern).centroids;
                    distance=(features-ones(length(features),1)*adjustedBoundary)*(centroids(notPatternCID,:)-centroids(patternCID,:))';
                    % samples with distance <0  are pattern #1
                    auPattern(iUnassigned(distance<0))=curPattern;
                end
                % Unassigned samples are assiged as unknown
                auPattern(auPattern=='UNASSIGNED')='UNK';
                if ACP.featureSpaceDisplayFlag,
                 aureaPlotFeatureSpace(features, ACP.pattern(iPattern), distance,  iPattern, ACP.showMsgs);
                end
                
                %     %Detect Outliers
                %     Outliers=zeros(size(AU_scores));
                %     % Detection Param/alphaCluster is defined so use it to detect
                %     % outliers
                %     if isfield(ClassificationParameters.OutlierMetadata.DetectionParam,'alphaCluster')
                %         %Based on cluster distance quantile
                %         for jndex=1:length(ClassificationParameters.PattOrder)
                %             thisPattCode=PatternCodes.(ClassificationParameters.PattOrder{jndex});
                %             ixThisPatt=find(AU_scores==thisPattCode);
                %
                %             %Select  the features to use
                %             strFeats='[';
                %             for kndex=1:length(ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}))
                %                 strFeats=[strFeats 'MetricsEach{index}.' ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}){kndex} '(ixThisPatt) '];
                %             end
                %             strFeats=[strFeats(1:end-1) ']'];
                %             features=eval(strFeats);
                %             %Standardize the current features
                %             ixTheseMetrics=ismember(AuxFields,ClassificationParameters.WhichMetrics.(ClassificationParameters.PattOrder{jndex}));
                %             features=(features-ones(size(features,1),1)*ClassificationParameters.metricMedian(ixTheseMetrics))./(ones(size(features,1),1)*ClassificationParameters.metricIQR(ixTheseMetrics));
                %             verbose([char(9) char(9) 'selecting and scaling features ... done'],ShowMsgs);
                %             auxCentroid=median(features,1); %The median of each column
                %             %               Compute distance of feature(s) from centroid(s)
                %             auxDist=pdist2(features,auxCentroid);
                %             auxGammaOutl=quantile(auxDist,1-ClassificationParameters.OutlierMetadata.DetectionParam.alphaCluster,1);
                %             Outliers(ixThisPatt(auxDist>auxGammaOutl))=1;
                %             ClassificationParameters.nOutLiers(index,jndex)=sum(Outliers);
                %             clear thisPattCode ixThisPatt auxDist auxGammaOutl
                %         end
                %     else
                %         % aplhaParam not defined so detect outliers from  metric
                %         % quantiles of current file
                %         Outliers=detectMetricOutliers(AuxMetrics,[],ClassificationParameters.OutlierMetadata,ShowMsgs);
                %         ClassificationParameters.nOutLiers(index,jndex)=sum(Outliers);
                %     end
                %     AU_scores(Outliers==1)=PatternCodes.UNK;
                %     verbose([char(9) char(9) 'setting outliers to UNK ... done'],ShowMsgs);
                %
                %Perform time averaging for MinPattLength
                auPattern=removecats(auPattern,'UNASSIGNED');
                pSeq{iFile,1}=auPattern;
                
            end
        end
%         
    end
end

