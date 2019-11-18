function [respatt_RCGABD_emstd,PattCodes,relpatt_RCGABD_emstd,Delta,NumIters] = resPatt_emPSEQ(ResPattPerScorer,Epsilon,MaxIter,GetAllIters,MinPattLength,ShowMsgs)
%RESPATT_EMPSEQ Estimates the "EM standard"
%   instantaneous respiratory pattern.
%   [respatt_RCGABD_empseq,PattCodes,relpatt_RCGABD_empseq] = resPatt_emPSEQ(ResPattPerScorer,Epsilon,MaxIter,GetAllIters,MinPattLength,ShowMsgs)
%       estimates the "EM standard" instantaneous
%       respiratory pattern using the manual scores
%       from 'ResPattPerScorer' and the
%       Expectation-Maximization procedure from [1].
%
%   INPUT
%   ResPattPerScorer is a 1-by-K struct
%       array with the respiratory pattern classification
%       for each of the K records under analysis.
%       Each cell 'i' is an Mi-by-S matrix with the
%       pattern assigned to the Mi samples by the S
%       scorers.
%   MaxIter is a scalar with the maximum number of
%       iterations used by the EM procedure.
%   GetAllIters is a flag indicating if the function
%       should return all iterations (default=false).
%   MinPattLength is a scalar with the minimum
%       pattern length in samples (default=25).
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output (default=false).
%
%   OUTPUT
%   respatt_RCGABD_empseq is an A-by-K struct with
%       the respiratory pattern classification for
%       each of the K records under analysis.
%       Each cell 'i' is an Mi-by-1 vector with the
%       "EM standard" patterns. If GetAllIters==false,
%       then A=1 and respatt_RCGABD_emstd returns only the
%       final iteration of the "EM standard". Else if
%       GetAllIters==true, then A=MaxIter+1 and respatt_RCGABD_emstd
%       gives each EM iteration. The final iteration
%       corresponds to the Ath element in the struct.
%   PattCodes is an struct array with the numerical
%       code for each of the respiratory patterns
%       in respatt_RCGABD_emstd.
%   relpatt_RCGABD_empseq is a 1-by-K struct array with
%       the reliability of each classification in
%       respatt_RCGABD_emstd.
%
%   EXAMPLE
%   [respatt_ALLxxx_empseq,~,relpatt_ALLxxx_empseq]=resPatt_emPSEQ(respatt_EACHxx_manuals);
%
%   VERSION HISTORY
%   2016_12_13 - Renamed to EM-PSEQ (CARR).
%   2016_04_12 - Renamed 'state' to 'pattern' (CARR).
%   2014_12_10 - Added to repository (CARR).
%   2012_01_14 - Created by: Carlos A. Robles-Rubio.
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

    if ~exist('MaxIter') | isempty(MaxIter)
        MaxIter=100;
    end    
    if ~exist('MinPattLength') | isempty(MinPattLength)
        MinPattLength=25;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    PattCodes.PAU=patternCode('PAU');
    PattCodes.ASB=patternCode('ASB');
    PattCodes.MVT=patternCode('MVT');
    PattCodes.SYB=patternCode('SYB');
    PattCodes.SIH=patternCode('SIH');
    PattCodes.UNK=patternCode('UNK');
    
    numScorers=size(ResPattPerScorer{1},2);
    numCases=length(ResPattPerScorer);
    lengthEach=zeros(numCases,1);
    for index=1:numCases
        lengthEach(index)=size(ResPattPerScorer{index},1);
    end

    %% Create scores matrix to run EM optimization
    ScoresData.Scores=zeros(0,numScorers);
    ScoresData.CaseID=zeros(0,1);
    ScoresData.IndxID=zeros(0,1);
    for index=1:numCases
        auxRespPattXScorer=ResPattPerScorer{index};
        auxRespPattXScorer(auxRespPattXScorer<1)=nan;         %Change 0s and -infs to missing values (NaN)
        ixGood=find(mean(isnan(auxRespPattXScorer),2)==0);   %Identify all samples scored by ALL scorers
        
        ScoresData.IndxID=[ScoresData.IndxID;ixGood];
        ScoresData.CaseID=[ScoresData.CaseID;ones(length(ixGood),1).*index];
        ScoresData.Scores=[ScoresData.Scores;auxRespPattXScorer(ixGood,:)];
        
        clear ixGood auxRespPattXScorer
    end
    ScoresData.Scores(ScoresData.Scores==PattCodes.UNK)=6; %Set UNKs to 6s
    
    %% Run EM optimization
    if GetAllIters
        auxW=[];
        W=[];
        W0=[];
        Q=[];
        P=[];
        Delta=nan(0,1);
        
        NumIters=0;
        while NumIters<MaxIter
            NumIters=NumIters+1;

            [auxW,auxW0,auxQ,auxP,~,auxDelta]=emStandard(ScoresData.Scores,auxW,Epsilon,1,ShowMsgs);
            if NumIters==1
                W0=auxW0;
            end
            W=cat(3,W,auxW);
            Q=cat(4,Q,auxQ);
            P=cat(3,P,auxP);
            Delta(NumIters)=auxDelta;
            clear auxW0 auxQ auxP auxDelta

            verbose(' ',ShowMsgs);
            verbose('######################################',ShowMsgs);
            verbose(['Iteration ' num2str(NumIters) ' completed. Delta = ' num2str(Delta(NumIters)) ' '],ShowMsgs);
            verbose('######################################',ShowMsgs);
            verbose(' ',ShowMsgs);
            
            if Delta(NumIters)<=Epsilon
                verbose([char(9) char(9) 'converged at ' num2str(NumIters) ' iterations. Delta = ' num2str(round(Delta(NumIters)*1000000)/1000000)],ShowMsgs);
                break;
            end
        end
        W=cat(3,W0,W);
    else
        [W,W0,Q,P,Labels,Delta,NumIters]=emStandard(ScoresData.Scores,[],Epsilon,MaxIter,ShowMsgs);
    end
    clear W0 Q P
    
    Reliability=[];
    EMScores=[];
    for ixIter=1:size(W,3)
        %"Em standard" is the pattern with maximum probability,
        %and reliability is the probability of the "em standard"
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
        EMScores=cat(3,EMScores,auxGold);
        Reliability=cat(3,Reliability,auxReli);
        clear auxReli auxGold
    end
    EMScores(EMScores==6)=PattCodes.UNK;       %Set 6s back to UNKs
    
    %% Re-arrange scores and reliability values
    respatt_RCGABD_emstd={};
    relpatt_RCGABD_emstd={};
    for ixIter=1:size(EMScores,3)
        for index=1:numCases
            %Define zero-valued temporary vectors with outputs
            AU_scores=zeros(lengthEach(index),1);
            AU_reliab=zeros(lengthEach(index),1);

            %Re-arrange output values
            goldThisCase=EMScores(ScoresData.CaseID==index,:,ixIter);
            AU_scores(ScoresData.IndxID(ScoresData.CaseID==index))=goldThisCase;
            reliThisCase=Reliability(ScoresData.CaseID==index,:,ixIter);
            AU_reliab(ScoresData.IndxID(ScoresData.CaseID==index))=reliThisCase;

            %Perform time averaging for MinPattLength
            tmp_scores=AU_scores;
            Tmp_scores=signal2events(tmp_scores); % convert to pseq
            elen_scores=Tmp_scores(:,2)-Tmp_scores(:,1)+1; % Event length 
            Tmp_scores(elen_scores<MinPattLength,3)=0; % If event is shorted than MinPatt length set type to 0; 
            tmp_scores=events2signal(Tmp_scores); % Convert to signal
            Tmp_scores=signal2events(tmp_scores); % Convert to events, concatonating type 0 events  
            AuxZeros=Tmp_scores(Tmp_scores(:,3)==0,:); % Pointer to type 0 events
            tmp_scores=events2signal(Tmp_scores); % Convert to  a signal 
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
                    prev=AuxZeros(jndex,1)-1; % index of precedding event
                    next=AuxZeros(jndex,2)+1;  % index of folllowing event
                    midp=floor((prev+next)/2); % Midpoint of short index 
                    tmp_scores(prev+1:midp)=tmp_scores(prev); % set first half to preceeding type 
                    tmp_scores(midp+1:next)=tmp_scores(next); % set second half to following type.
                end
            end

            AU_scores=tmp_scores;

            respatt_RCGABD_emstd{ixIter,index}=AU_scores;
            relpatt_RCGABD_emstd{ixIter,index}=AU_reliab;
        end
    end
end