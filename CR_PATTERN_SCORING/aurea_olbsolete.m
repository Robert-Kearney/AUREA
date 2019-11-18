function [ClassifiedData,Features,ClassificationParameters] = aurea(InputData,Np,Nq,Nm,Na,Nr,Nb,Navg,Fs,ClassificationParameters)
%AUREA Performs the Automated Unsupervised Respiratory Event Analysis
%   [ClassifiedData,Features] = aurea(InputData,Np,Nq,Nm,Na,Nr,Fs) performs
%   the original AUREA [1] with input InputData.
%   InputData is an S-by-1 cell array with the data from each subject
%      in each cell. Each cell is an M-by-2 matrix with the Ribcage
%      signal in the first column and the Abdomen signal in the
%      second one.
%   Np is a scalar value with the length (in sample points) of the
%      sliding window for the Pause Test Statistic.
%   Nq is a scalar value with the length (in sample points) of the
%      sliding window for the Pause Test Statistic. Nq >> Np,Nm,Na,Nr.
%   Nm is a scalar value with the length (in sample points) of the
%      sliding window for the Movement Test Statistic.
%   Na is a scalar value with the length (in sample points) of the
%      sliding window for the Asynchrony Test Statistic.
%   Nr is a scalar value with the length (in sample points) of the
%      sliding window for the RMS Test Statistic.
%   Nb is a scalar value with the length (in sample points) of the
%      sliding window for the Breathing Test Statistics.
%   Navg is a scalar value with the length (in sample points) of the
%      smoothing window for the Breathing Test Statistics.
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   ClassifiedData is an struct array with the classified data for
%      each subject in each cell. Each cell is an M-by-1 vector with
%      the classification values (respiratory state).
%   Features is a cell array with the values of the Test Statistics
%      computed for each subject.
%
%   Version 1.0: Carlos A. Robles-Rubio.
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Conf. Proc. 33rd IEEE Eng. Med. Biol. Soc., Boston,
%       USA, 2011, pp. 3201-3204.
%
%
%Copyright (c) 2011-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

deprecate({'CardiorespiratoryMetrics';'respState_originalAUREA'});

if ~exist('Fs') | isempty(Fs)
    Fs=50;
end

testOnly=false;
if ~exist('ClassificationParameters') | isempty(ClassificationParameters)
    ClassificationParameters={};
else
    testOnly=true;
end

if Nq<Np | Nq<Nm | Nq<Na | Nq<Nr | Nq<Nb | Nq<Navg
    display(['Error: Nq must be >> Np,Nm,Na,Nr.']);
    return;
end

PAUSE=1;
ASYNCH=2;
MOVEMENT=3;
NORMBREATH=4;
BreathFreqs=[0.1:0.15:1.9]';

clearanceSamples=floor(max([Np;Nm;Na;Nr])/2);

prc=[];
pab=[];
mrc=[];
mab=[];
phi=[];
rms=[];
fmx=[];
brc=[];
bab=[];
bsu=[];
bdi=[];
bph=[];

Features.prc={};
Features.pab={};
Features.mrc={};
Features.mab={};
Features.phi={};
Features.rms={};
Features.fmx={};
Features.brc={};
Features.bab={};
Features.bsu={};
Features.bdi={};
Features.bph={};

numFiles=length(InputData);
lengthEach=zeros(numFiles,1);

for index=1:numFiles
    aux=InputData{index};
    RC=aux(:,1);
    AB=aux(:,2);
    
    if(~isempty(Nq))
        lengthEach(index)=length(RC)-Nq-clearanceSamples+1;
    else
        lengthEach(index)=length(RC)-2*clearanceSamples;
    end

    [aprc]=pauseStat(RC,Np,Nq,Fs);
    [apab]=pauseStat(AB,Np,Nq,Fs);
    [amrc]=mvtStat(RC,Nm,Fs);
    [amab]=mvtStat(AB,Nm,Fs);
    [aphi,afmx]=asynchStat(RC,AB,Na,Fs);
    [arms]=rmsStat(RC,AB,Nr);
    [abrc,abab,absu,abdi,abph]=breathStat(RC,AB,Nb,Nb,Navg,Fs);
    if(~isempty(Nq))
        Features.prc{index}=[nan(Nq-1,1);aprc(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.pab{index}=[nan(Nq-1,1);apab(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.mrc{index}=[nan(Nq-1,1);amrc(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.mab{index}=[nan(Nq-1,1);amab(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.phi{index}=[nan(Nq-1,1);aphi(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.rms{index}=[nan(Nq-1,1);arms(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.fmx{index}=[nan(Nq-1,1);BreathFreqs(afmx(Nq:end-clearanceSamples));nan(clearanceSamples,1)];
        Features.brc{index}=[nan(Nq-1,1);abrc(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bab{index}=[nan(Nq-1,1);abab(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bsu{index}=[nan(Nq-1,1);absu(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bdi{index}=[nan(Nq-1,1);abdi(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bph{index}=[nan(Nq-1,1);abph(Nq:end-clearanceSamples);nan(clearanceSamples,1)];
        
        prc=[prc;aprc(Nq:end-clearanceSamples)];
        pab=[pab;apab(Nq:end-clearanceSamples)];
        mrc=[mrc;amrc(Nq:end-clearanceSamples)];
        mab=[mab;amab(Nq:end-clearanceSamples)];
        phi=[phi;aphi(Nq:end-clearanceSamples)];
        rms=[rms;arms(Nq:end-clearanceSamples)];
        fmx=[fmx;BreathFreqs(afmx(Nq:end-clearanceSamples))];
        brc=[brc;abrc(Nq:end-clearanceSamples)];
        bab=[bab;abab(Nq:end-clearanceSamples)];
        bsu=[bsu;absu(Nq:end-clearanceSamples)];
        bdi=[bdi;abdi(Nq:end-clearanceSamples)];
        bph=[bph;abph(Nq:end-clearanceSamples)];
    else
        Features.prc{index}=[nan(clearanceSamples,1);aprc(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.pab{index}=[nan(clearanceSamples,1);apab(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.mrc{index}=[nan(clearanceSamples,1);amrc(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.mab{index}=[nan(clearanceSamples,1);amab(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.phi{index}=[nan(clearanceSamples,1);aphi(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.rms{index}=[nan(clearanceSamples,1);arms(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.fmx{index}=[nan(clearanceSamples,1);BreathFreqs(afmx(clearanceSamples+1:end-clearanceSamples));nan(clearanceSamples,1)];
        Features.brc{index}=[nan(clearanceSamples,1);abrc(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bab{index}=[nan(clearanceSamples,1);abab(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bsu{index}=[nan(clearanceSamples,1);absu(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bdi{index}=[nan(clearanceSamples,1);abdi(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        Features.bph{index}=[nan(clearanceSamples,1);abph(clearanceSamples+1:end-clearanceSamples);nan(clearanceSamples,1)];
        
        prc=[prc;aprc(clearanceSamples+1:end-clearanceSamples)];
        pab=[pab;apab(clearanceSamples+1:end-clearanceSamples)];
        mrc=[mrc;amrc(clearanceSamples+1:end-clearanceSamples)];
        mab=[mab;amab(clearanceSamples+1:end-clearanceSamples)];
        phi=[phi;aphi(clearanceSamples+1:end-clearanceSamples)];
        rms=[rms;arms(clearanceSamples+1:end-clearanceSamples)];
        fmx=[fmx;BreathFreqs(afmx(clearanceSamples+1:end-clearanceSamples))];
        brc=[brc;abrc(clearanceSamples+1:end-clearanceSamples)];
        bab=[bab;abab(clearanceSamples+1:end-clearanceSamples)];
        bsu=[bsu;absu(clearanceSamples+1:end-clearanceSamples)];
        bdi=[bdi;abdi(clearanceSamples+1:end-clearanceSamples)];
        bph=[bph;abph(clearanceSamples+1:end-clearanceSamples)];
    end
    
    clear aux RC AB;
end

%% =================================
%% ........The classification.......
%% =================================
startPointP=[log(0.1),log(0.1),0,0,log(0.1);
    0,0,0,0,log(0.1);
    0,0,-1,-1,1;
    0,0,1,1,log(0.1)];
features=[log(prc) log(pab) mrc mab log(rms)];
if ~testOnly
    [IDXp,Cp]=kmeans(features,4,'options',statset('MaxIter',150),'start',startPointP);
    w1PM=mean(IDXp==PAUSE)/(mean(IDXp==MOVEMENT)+mean(IDXp==PAUSE));
    w1PA=mean(IDXp==PAUSE)/(mean(IDXp==ASYNCH)+mean(IDXp==PAUSE));
    w1PQ=mean(IDXp==PAUSE)/(mean(IDXp==NORMBREATH)+mean(IDXp==PAUSE));
    gammaPM=(Cp(MOVEMENT,:)-Cp(PAUSE,:)).*w1PM+Cp(PAUSE,:);
    gammaPA=(Cp(ASYNCH,:)-Cp(PAUSE,:)).*w1PA+Cp(PAUSE,:);
    gammaPQ=(Cp(NORMBREATH,:)-Cp(PAUSE,:)).*w1PQ+Cp(PAUSE,:);
    
    ClassificationParameters.gammaPM=gammaPM;
    ClassificationParameters.gammaPA=gammaPA;
    ClassificationParameters.gammaPQ=gammaPQ;
    ClassificationParameters.Cp=Cp;
else
    Cp=ClassificationParameters.Cp;
    gammaPM=ClassificationParameters.gammaPM;
    gammaPA=ClassificationParameters.gammaPA;
    gammaPQ=ClassificationParameters.gammaPQ;
end
distPM=(features-ones(length(features),1)*gammaPM)*(Cp(MOVEMENT,:)-Cp(PAUSE,:))';
distPA=(features-ones(length(features),1)*gammaPA)*(Cp(ASYNCH,:)-Cp(PAUSE,:))';
distPQ=(features-ones(length(features),1)*gammaPQ)*(Cp(NORMBREATH,:)-Cp(PAUSE,:))';
IDXp(and(distPM<0,and(distPA<0,distPQ<0)))=PAUSE;
IDXp(not(and(distPM<0,and(distPA<0,distPQ<0))))=0;

startPointM=[0,0,-1,-1,1;
    0,0,1,1,log(0.1)];
features=[log(prc(IDXp~=1)) log(pab(IDXp~=1)) mrc(IDXp~=1) mab(IDXp~=1) log(rms(IDXp~=1))];
iBreath=2;
iEvent=1;
if ~testOnly
    [IDXm,Cm]=kmeans(features,2,'options',statset('MaxIter',150),'start',startPointM);
    w1M=mean(IDXm==iEvent);
    gammaWM=((Cm(iBreath,:)-Cm(iEvent,:)).*w1M+Cm(iEvent,:));
    
    ClassificationParameters.gammaWM=gammaWM;
    ClassificationParameters.Cm=Cm;
else
    gammaWM=ClassificationParameters.gammaWM;
    Cm=ClassificationParameters.Cm;
end
distM=(features-ones(length(features),1)*gammaWM)*(Cm(iBreath,:)-Cm(iEvent,:))';

startPointA=[0;1];
features=phi(IDXp~=1);
features=features(distM>=0);
iBreath=1;
iEvent=2;
if ~testOnly
    [IDXa,Ca]=kmeans(features,2,'options',statset('MaxIter',150),'start',startPointA);
    w1Q=mean(IDXa==iBreath);
    gammaWA=((Ca(iEvent,:)-Ca(iBreath,:)).*w1Q+Ca(iBreath,:));
    
    ClassificationParameters.gammaWA=gammaWA;
    ClassificationParameters.Ca=Ca;
else
    gammaWA=ClassificationParameters.gammaWA;
    Ca=ClassificationParameters.Ca;
end
distA=(features-ones(length(features),1)*gammaWA)*(Ca(iEvent,:)-Ca(iBreath,:))';

AU_scores=zeros(length(prc),1);
AU_scores(IDXp==1)=PAUSE;
indexEvents2=find(IDXp~=1);
AU_scores(indexEvents2(distM<0))=MOVEMENT;
indexEvents3=indexEvents2(distM>=0);
AU_scores(indexEvents3(distA<=0))=NORMBREATH;
AU_scores(indexEvents3(distA>0))=ASYNCH;

ClassifiedData={};
count=1;
for index=1:numFiles
    if(~isempty(Nq))
        ClassifiedData{index}=[zeros(Nq-1,1);AU_scores(count:count+lengthEach(index)-1);zeros(clearanceSamples,1)];
    else
        ClassifiedData{index}=[zeros(clearanceSamples,1);AU_scores(count:count+lengthEach(index)-1);zeros(clearanceSamples,1)];
    end
    count=count+lengthEach(index);
end

end