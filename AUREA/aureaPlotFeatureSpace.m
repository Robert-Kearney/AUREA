function aureaPlotFeatureSpace (features, pattern, distance, figNum, showMsgs)
%% Plot feature space
    if showMsgs,
        figure(figNum);
        [nSamp,nFeature]=size(features);
        i1=find(distance<0);
        i2=find(distance>0);
        
        if nFeature==1,
            plot(features(i1,1)*0+1,features(i1,1),'.', features(i2,1)*0+2,features(i2,1),'.r')
            h=line([ 1 2],[pattern.adjustedBoundary pattern.adjustedBoundary]);
             set(h,'marker','o','markersize',12,'markerfacecolor','g','linestyle','-')
            
            set(gca,'xlim',[0 3]);
            ylabel(pattern.whichMetrics{1});
            title(pattern.whichPattern);
            
            
            set(h,'marker','o','markersize',12,'markerfacecolor','g','linestyle','none')
        else
            plot(features(i1,1),features(i1,2),'.', features(i2,1),features(i2,2),'.r')
            h=line(pattern.adjustedBoundary(1), pattern.adjustedBoundary(2));
            set(h,'marker','o','markersize',12,'markerfacecolor','g','linestyle','none')
            
            curPattern=pattern.whichPattern;
            title(curPattern);
            xlabel(pattern.whichMetrics{1});
            ylabel(pattern.whichMetrics{2});
            legend(curPattern,'Other','Centroid')
        end
    end