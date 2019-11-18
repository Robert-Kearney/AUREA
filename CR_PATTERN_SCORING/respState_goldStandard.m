function [RespiratoryState,StateCodes,ReliabilityClassif] = respState_goldStandard(RespiratoryStatePerScorer,MaxIter,GetAllIters,MinStateLength,ShowMsgs)
%RESPSTATE_GOLDSTANDARD Estimates the EM  "gold standard"  instantaneous respiratory state.
%   [RespiratoryState,StateCodes,ReliabilityClassif] = respState_goldStandard(RespiratoryStatePerScorer,MaxIter,GetAllIters,MinStateLength,ShowMsgs)
%       estimates the "gold standard" instantaneous
%       respiratory state using the manual scores
%       from 'RespiratoryStatePerScorer' and the
%       Expectation-Maximization procedure from [1].
%
%   INPUT
%   RespiratoryStatePerScorer is a 1-by-K struct
%       array with the respiratory state classification
%       for each of the K records under analysis.
%       Each cell 'i' is an Mi-by-S matrix with the
%       state assigned to the Mi samples by the S
%       scorers.
%   MaxIter is a scalar with the maximum number of
%       iterations used by the EM procedure.
%   GetAllIters is a flag indicating if the function
%       should return all iterations (default=false).
%   MinStateLength is a scalar with the minimum
%       state length in samples (default=25).
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output (default=false).
%
%   OUTPUT
%   RespiratoryState is an A-by-K struct with
%       the respiratory state classification for
%       each of the K records under analysis.
%       Each cell 'i' is an Mi-by-1 vector with the
%       "gold standard" states. If GetAllIters==false,
%       then A=1 and RespiratoryState returns only the
%       final iteration of the gold standard. Else if
%       GetAllIters==true, then A=MaxIter+1 and RespiratoryState
%       gives each EM iteration. The final iteration
%       corresponds to the Ath element in the struct.
%   StateCodes is an struct array with the numerical
%       code for each of the respiratory states
%       in RespiratoryState.
%   ReliabilityClassif is a 1-by-K struct array with
%       the reliability of each classification in
%       RespiratoryState.
%
%   EXAMPLE
%   [respstt_ALLxxx_emgolds,~,relistt_ALLxxx_emgolds]=respState_goldStandard(respstt_EACHxx_manuals);
%
%   VERSION HISTORY
%   2016_04_09 - Deprecated the function (CARR).
%   2014_12_10 - Added to repository (CARR).
%   2012_01_14 - Created by Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] .
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

    deprecate({'resPatt_goldStd'});

    if ~exist('MaxIter') | isempty(MaxIter)
        MaxIter=100;
    end    
    if ~exist('MinStateLength') | isempty(MinStateLength)
        MinStateLength=25;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    StateCodes.PAU=stateCode('PAU');
    StateCodes.ASB=stateCode('ASB');
    StateCodes.MVT=stateCode('MVT');
    StateCodes.SYB=stateCode('SYB');
    StateCodes.SIH=stateCode('SIH');
    StateCodes.UNK=stateCode('UNK');
    
    numScorers=size(RespiratoryStatePerScorer{1},2);
    numCases=length(RespiratoryStatePerScorer);
    lengthEach=zeros(numCases,1);
    for index=1:numCases
        lengthEach(index)=size(RespiratoryStatePerScorer{index},1);
    end

    %% Create scores matrix to run EM optimization
    ScoresData.Scores=zeros(0,numScorers);
    ScoresData.CaseID=zeros(0,1);
    ScoresData.IndxID=zeros(0,1);
    for index=1:numCases
        auxRespSttXScorer=RespiratoryStatePerScorer{index};
        auxRespSttXScorer(auxRespSttXScorer<1)=nan;         %Change 0s and -infs to missing values (NaN)
        ixGood=find(mean(isnan(auxRespSttXScorer),2)==0);   %Identify all samples scored by ALL scorers
        
        ScoresData.IndxID=[ScoresData.IndxID;ixGood];
        ScoresData.CaseID=[ScoresData.CaseID;ones(length(ixGood),1).*index];
        ScoresData.Scores=[ScoresData.Scores;auxRespSttXScorer(ixGood,:)];
        
        clear ixGood auxRespSttXScorer
    end
    ScoresData.Scores(ScoresData.Scores==StateCodes.UNK)=6; %Set UNKs to 6s
    
    %% Run EM optimization
    if GetAllIters
        auxW=[];
        W=[];
        W0=[];
        Q=[];
        P=[];
        Delta.sad=[];
        Delta.mad=[];
        for ixIter=1:MaxIter
            [auxW,auxW0,auxQ,auxP,~,auxDelta]=emGoldStandard(ScoresData.Scores,1,auxW,ShowMsgs);
            if ixIter==1
                W0=auxW0;
            end
            W=cat(3,W,auxW);
            Q=cat(4,Q,auxQ);
            P=cat(3,P,auxP);
            Delta.sad=[Delta.sad;auxDelta.sad];
            Delta.mad=[Delta.mad;auxDelta.mad];
            clear auxW0 auxQ auxP auxDelta
        end
        W=cat(3,W0,W);
    else
        [W,W0,Q,P,~,Delta]=emGoldStandard(ScoresData.Scores,MaxIter,[],ShowMsgs);
    end
    clear W0 Q P
    
    Reliability=[];
    GoldScores=[];
    for ixIter=1:size(W,3)
        %"Gold standard" is the state with maximum probability,
        %and reliability is the probability of the "gold standard"
        [auxReli,auxGold]=max(W(:,:,ixIter),[],2);
        
        %Identify if there are any ties
        ixMode=W(:,:,ixIter)==auxReli*ones(1,size(W(:,:,ixIter),2));
        numModes=sum(ixMode,2);
        hasTies=numModes>1;
        NumTies=sum(hasTies);

        %If ties, select one of the tied patterns at random
        if NumTies>0
            newGoldTies=nan(NumTies,1);
            ixModeTies=ixMode(hasTies,:);
            
            %Go row by row and select the MV pattern at random from ties
            for ixTiedRow=1:NumTies
                auxPatts=find(ixModeTies(ixTiedRow,:));         %The tied patterns
                newGoldTies(ixTiedRow)=randsample(auxPatts,1);	%The new pattern selected at random
            end
            
            auxGold(hasTies)=newGoldTies;   %Re-assign samples with ties to random selection
        end
        
        %Store
        GoldScores=cat(3,GoldScores,auxGold);
        Reliability=cat(3,Reliability,auxReli);
        clear auxReli auxGold
    end
    GoldScores(GoldScores==6)=StateCodes.UNK;       %Set 6s back to UNKs
    
    %% Re-arrange scores and reliability values
    RespiratoryState={};
    ReliabilityClassif={};
    for ixIter=1:size(GoldScores,3)
        for index=1:numCases
            %Define zero-valued temporary vectors with outputs
            AU_scores=zeros(lengthEach(index),1);
            AU_reliab=zeros(lengthEach(index),1);

            %Re-arrange output values
            goldThisCase=GoldScores(ScoresData.CaseID==index,:,ixIter);
            AU_scores(ScoresData.IndxID(ScoresData.CaseID==index))=goldThisCase;
            reliThisCase=Reliability(ScoresData.CaseID==index,:,ixIter);
            AU_reliab(ScoresData.IndxID(ScoresData.CaseID==index))=reliThisCase;

            %Perform time averaging for MinStateLength
            tmp_scores=AU_scores;
            Tmp_scores=signal2events(tmp_scores);
            elen_scores=Tmp_scores(:,2)-Tmp_scores(:,1)+1;
            Tmp_scores(elen_scores<MinStateLength,3)=0;
            tmp_scores=events2signal(Tmp_scores);
            Tmp_scores=signal2events(tmp_scores);
            AuxZeros=Tmp_scores(Tmp_scores(:,3)==0,:);
            tmp_scores=events2signal(Tmp_scores);
            ixSt=1;
            ixEn=size(AuxZeros,1);
            if ixEn>0
                if AuxZeros(1,1)==1
                    ixSt=ixSt+1;
                end
                if AuxZeros(end,2)==lengthEach(index)
                    ixEn=ixEn-1;
                end
                for jndex=ixSt:ixEn
                    prev=AuxZeros(jndex,1)-1;
                    next=AuxZeros(jndex,2)+1;
                    midp=floor((prev+next)/2);
                    tmp_scores(prev+1:midp)=tmp_scores(prev);
                    tmp_scores(midp+1:next)=tmp_scores(next);
                end
            end

            AU_scores=tmp_scores;

            RespiratoryState{ixIter,index}=AU_scores;
            ReliabilityClassif{ixIter,index}=AU_reliab;
        end
    end
end