function aureaPlot ( ixCase, ixEpoch, EpochLen, signals,  auPatterns)
%Plot raw data and aureasuea classifcations for an epoch 
startOffset=500;
ShowMsgs=true;


SYB=patternCode('SYB');
ASB=patternCode('ASB');
SIH=patternCode('SIH');
MVT=patternCode('MVT');
PAU=patternCode('PAU');

Fs=50;
iStart=ixEpoch-startOffset;
iEnd=ixEpoch+(EpochLen*Fs)-1;
X=signals{ixCase}(iStart:iEnd,:);
%% Limit Sat to 100
X(:,4)=min(X(:,4),100);
%% Plot Signals 
t=(1:length(X))/Fs;
UNK=patternCode('UNK');
patterns=[SYB,ASB,SIH,PAU,MVT,UNK]';
numPatterns=length(patterns);
clf
chanLabel={ 'Ribcage' 'Abdomen' 'PPG' 'Saturation'};
yLabels= {'AU' 'AU' 'AU' '%' };
for i=1:4,
subplot(5,1,i);
plot(t,X(:,i))
set(gca,'xticklabel',[], 'xlim',[0 EpochLen]);
ylabel (yLabels{i}); 
title(chanLabel{i}); 
end

% Plot PSEQs

width=2.;
offset=0;

yTick=[];
subplot (5,1,5);
%Add patches for legend
for ixPattern=1:numPatterns
    patch([-100 -99 -99 -100],[-100 -100 -99 -99],patternColor(patterns(ixPattern)));
end
   k=0;
   % offset=offset-width;

  
   
%% Plot AU Patterns   
 edgeColorFlag=true; 
offset=offset-width; 
    p=auPatterns{ixCase}(iStart:iEnd,:);
    auEvents=cseq2eseq(p);  
   eseqPlot (auEvents,offset,width,Fs,ShowMsgs, edgeColorFlag);
   yTick=[yTick offset];
 %%  
   yTick=fliplr(yTick)+width/2;
   set(gca,'xlim',[0 50]);
   set( gca, 'ytick',yTick, 'ytickLabel' ,{'AUREA' 'EM' 'IS(6)' 'IS(5)' ...
       'IS(4)' 'IS(3)' 'IS(2)' 'IS(1)' ...
       });
   xlabel (['Time (s)  Offset=' num2str((ixEpoch-startOffset)/Fs)]); 
legend('SYB','ASB','SIH','PAU','MVT','UNK','Orientation','horizontal','Location','northoutside');
 set(gca,'ylim',[-6 0]); 
%
  
   
          