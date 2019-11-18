function [stateDen,stateFre,stateMax,stateMin,stateMed,stateLoQ,stateHiQ,stateEnt,stateSet] = patternStat(X,Nstate,kent,states,minLen,normalizeToTotal,Fs,flagWaitBar)
%STATESTATS Estimates the statistics derived from the cardiorespiratory state
%   [stateDen,stateFre] = patternStat(X,Ndens,minLen,normalizeToTotal,Fs)
%   estimates the state statistics in a window of length Ndens samples.
%
%   INPUT
%   X is an M-by-1 vector with the cardiorespiratory
%      state from the subject.
%   Ndens is a scalar value with the length (in sample
%      points) of the sliding window for the state statistics.
%   kent is a scalar value with the number of points used
%      for the PMF used to estimate entropy.
%   states is a vector with the list of possible states
%      in X.
%   minLen is a scalar value with the minimum length
%      (in sample points) required by a state to be
%      considered in the statistics estimation
%      (default=2*Fs).
%   normalizeToTotal is a logical value indicating
%      whether the density estimation should be normalized
%      with respect to the full window length
%      (normalizeToTotal=true, default), or with
%      respect to the number of samples left after
%      discarding all segments with length < minLen
%      (normalizeToTotal=false). False not implemented yet.
%   Fs is a scalar value with the sampling frequency
%      (default=50Hz).
%
%   OUTPUT
%   ClassifiedData is an struct array with the classified data for
%      each subject in each cell. Each cell is an M-by-1 vector with
%      the classification values.
%   Features is a cell array with the values of the Test Statistics
%      computed for each subject.
%
%   Version 1.0: Carlos A. Robles-Rubio.
%
%   References:
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

    if ~exist('flagWaitBar') | isempty(flagWaitBar)
        flagWaitBar=false;
    end

    if ~exist('normalizeToTotal') | isempty(normalizeToTotal)
        normalizeToTotal=true;
    end

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    
    if ~exist('minLen') | isempty(minLen)
        minLen=2*Fs;
    end

    if flagWaitBar
        myWaitBar=waitbar(0,'Calculating State Stats, please wait...');
    end
    
    sigLength=length(X);
    numStates=length(states);
    
    AuxEvts=signal2events(X);
    ixTooShort=(AuxEvts(:,2)-AuxEvts(:,1)+1)<minLen;
    AuxEvts(ixTooShort,3)=0;
    X=events2signal(AuxEvts);
    
    stateDen=nan(sigLength,numStates);
    stateFre=nan(size(stateDen));
    stateMax=nan(size(stateDen));
    stateMin=nan(size(stateDen));
    stateMed=nan(size(stateDen));
    stateLoQ=nan(size(stateDen));
    stateHiQ=nan(size(stateDen));
    stateEnt=nan(size(stateDen));
    stateSet=nan(size(stateDen));
    
    b=ones(Nstate,1)./Nstate;
    counter=0;
    for index=1:numStates
        Xaux=(X==states(index))+0;
        
        %State Density
        stateDen(:,index)=filternc(b,Xaux,2);
        
        for jndex=1:sigLength-Nstate+1
            counter=counter+1;
            
            mywin=jndex:jndex+Nstate-1;
            lenmywin=length(mywin);
            EvtXmywin=signal2events(Xaux(mywin));
            
            %State Frequency
            stateFre(jndex+floor(Nstate/2),index)=(sum(EvtXmywin(:,3)==1)/lenmywin)*Fs;
            
            %State length order statistics
            EvtXlens=(EvtXmywin(:,2)-EvtXmywin(:,1)+1)./Fs;
            stateMin(jndex+floor(Nstate/2),index)=min(EvtXlens);
            stateMax(jndex+floor(Nstate/2),index)=max(EvtXlens);
            auxQtl=quantile(EvtXlens,[0.25,0.5,0.75]);
            stateLoQ(jndex+floor(Nstate/2),index)=auxQtl(1);
            stateMed(jndex+floor(Nstate/2),index)=auxQtl(2);
            stateHiQ(jndex+floor(Nstate/2),index)=auxQtl(3);
            
%             %Entropy
%             [mypdf,mycen]=hist(X(mywin),kent);
%             mypdf=mypdf./(Nstate);
%             aux=mypdf.*log(mypdf)./log(1/kent);
%             stateEnt(jndex+floor(Nstate/2),index)=-sum(aux(~isnan(aux)));

%             %Spectral entropy

            if flagWaitBar
                waitbar(counter/(numStates*(sigLength-Nstate+1)));
            end
        end
    end
    
    if flagWaitBar
        close(myWaitBar);
    end
end