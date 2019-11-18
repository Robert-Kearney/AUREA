function [Outliers,OutlierMetadata] = detectMetricOutliers(Metrics,DetectionParam,OutlierMetadata,ShowMsgs)
%DETECTMETRICOUTLIERS Detects outliers in AUREA's cardiorespiratory metrics.
%   [Outliers,OutlierMetadata]=detectMetricOutliers(Metrics,DetectionParam,OutlierMetadata,ShowMsgs)
%       detects outliers in AUREA's cardiorespiratory
%       metrics for use in state classification.
%
%   INPUT
%   Metrics is a cell array with the values of the
%       computed cardiorespiratory metrics as output
%       by CardiorespiratoryMetrics.
%   DetectionParam is a struct array containing
%       the parameters for outlier identification.
%   OutlierMetadata is a cell array with the outlier
%       detection thresholds and parameters used to
%       estimate them, as output by this function
%       (detectMetricOutliers).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   Outliers is a binary vector with the metric
%       outlier detection results. Metric outliers
%       are where Outliers==1.
%   OutlierMetadata is a cell array with the outlier
%       detection thresholds and parameters used to
%       estimate them.
%
%   EXAMPLE
%   %For training
%   [~,OutlierMetadata]=detectMetricOutliers(Metrics,DetectionParam,[],ShowMsgs);
%   %For testing
%   [Outliers]=detectMetricOutliers(Metrics,[],OutlierMetadata,ShowMsgs);
%
%   VERSION HISTORY
%   2014_01_09 - Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1]
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

    %Default values
    if ~exist('DetectionParam') | isempty(DetectionParam)
        DetectionParam.alphaMetrics=0.001;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    %% Training
    if ~exist('OutlierMetadata') | isempty(OutlierMetadata)
        verbose(['Obtaining order statistics from metrics ...'],ShowMsgs);
        
        %Add detection parameters to output
        OutlierMetadata.DetectionParam=DetectionParam;
        
        %Identify the metrics used
        OutlierMetadata.WhichMetrics=fields(Metrics);
        
        %Build matrix of metrics
        % nFiles= size(Metrics.(OutlierMetadata.WhichMetrics{1})
        % nMetric = size(OutlierMetadata.WhichMetrics,1)
        MetricMatrix=nan(size(Metrics.(OutlierMetadata.WhichMetrics{1}),1),size(OutlierMetadata.WhichMetrics,1));
        for index=1:size(MetricMatrix,2)
            MetricMatrix(:,index)=Metrics.(OutlierMetadata.WhichMetrics{index});
        end
        MetricMatrix=MetricMatrix(~isnan(sum(MetricMatrix,2)),:);
        
        %Median and quantiles of metrics
        OutlierMetadata.median=nanmedian(MetricMatrix,1);
        OutlierMetadata.iqr=iqr(MetricMatrix,1);
        auxqtl=quantile(MetricMatrix,[OutlierMetadata.DetectionParam.alphaMetrics/2 1-OutlierMetadata.DetectionParam.alphaMetrics/2],1);
        OutlierMetadata.lowerQuantile=auxqtl(1,:);
        OutlierMetadata.upperQuantile=auxqtl(2,:);
        verbose([char(9) 'order statistics from metrics ... done'],ShowMsgs);
        
        clear MetricMatrix auxqtl
    end
    
    %% Detection
    verbose(['Detecting outliers ...'],ShowMsgs);
    
    %Build matrix of metrics
    MetricMatrix=nan(size(Metrics.(OutlierMetadata.WhichMetrics{1}),1),size(OutlierMetadata.WhichMetrics,1));
    for index=1:size(MetricMatrix,2)
        MetricMatrix(:,index)=Metrics.(OutlierMetadata.WhichMetrics{index});
    end
    
    %Initialize aux scores
    Outliers=zeros(size(MetricMatrix,1),1);
        
    %Detect outliers using lower and upper quantiles
    for index=1:size(MetricMatrix,2)
        Outliers(MetricMatrix(:,index)<OutlierMetadata.lowerQuantile(index))=1;
        Outliers(MetricMatrix(:,index)>OutlierMetadata.upperQuantile(index))=1;
    end
    
    %Set nan inputs to nan outputs
    Outliers(isnan(sum(MetricMatrix,2)))=nan;
    verbose([char(9) 'detecting outliers ... done'],ShowMsgs);
end