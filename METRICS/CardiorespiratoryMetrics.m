function [Metrics,MetricMetadata] = CardiorespiratoryMetrics(RCG,ABD,PPG,SAT,ECG,Metric_param,Denoise,Fs,ShowMsgs)
%CARDIORESPIRATORYMETRICS Estimates AUREA's cardiorespiratory metrics.
%   [Metrics] = CardiorespiratoryMetrics(InputData,Metric_param,Fs)
%       estimates AUREA's cardiorespiratory metrics
%       from the input signals.
%
%   INPUT
%   RCG is an M-by-1 vector with the data from the
%       ribcage signal.
%   ABD is an M-by-1 vector with the data from the
%       abdomen signal.
%   PPG is an M-by-1 vector with the data from the
%       photoplethysmography signal.
%   SAT is an M-by-1 vector with the data from the
%       blood oxygen saturation signal.
%   ECG is an M-by-1 vector with the data from the
%       electrocardiogram signal.
%   Metric_param is a struct array containing the parameters
%       for all the cardiorespiratory metrics.
%   Denoise is a flag indicating if the metrics
%       should be estimated from the signal component
%       estimate (default=false).
%   Fs is a scalar value with the sampling frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   Metrics is a cell array with the values of the
%       computed cardiorespiratory metrics.
%   MetricMetadata is a cell array with the runtime
%       parameters used to compute the metrics.
%
%   EXAMPLE
%   [Metrics,MetricMetadata]=CardiorespiratoryMetrics(RCG,ABD,PPG,SAT,ECG,[],false,Fs,false);
%
%   VERSION HISTORY
%   2014_10_24 - Function now accepts signals with NaN segments (CARR).
%   2014_10_24 - Low-pass filtering zeroxng estimates (CARR).
%   2014_10_23 - Added RMS for RCG and ABD (CARR).
%   2013_11_07 - Created by: Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Automated Unsupervised Respiratory Event Analysis,"
%       in Proc. 33rd IEEE Ann. Int. Conf. Eng. Med. Biol. Soc.,
%       Boston, USA, 2011, pp. 3201-3204.
%
%
%Copyright (c) 2013-2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('Denoise','var') || isempty(Denoise)
        Denoise=false;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end
    if ~exist('Metric_param','var') || isempty(Metric_param)
        % Default values for parameters used to copute aurea metrics
        Metric_param.sig2noi.NfPPG=65;
        Metric_param.sig2noi.NavgPPG=11;
        Metric_param.sig2noi.NfRIP=251;
        Metric_param.sig2noi.NavgRIP=25;
        Metric_param.sig2noi.M=10;
        Metric_param.sig2noi.Mu=0.005;
        Metric_param.sig2noi.Nsnr=251;
        Metric_param.sig2noi.MaxH_fR=3;
        Metric_param.sig2noi.MaxH_fC=3;
        Metric_param.sig2noi.epsilon=0.01;
        Metric_param.respfrq.Nf=Metric_param.sig2noi.NfRIP;
        Metric_param.respfrq.Navg=Metric_param.sig2noi.NavgRIP;
        Metric_param.respfrq.zeroxng.Fl=2*1.5;                  %The cut-off freq (Hz) of the low-pass filter
        Metric_param.respfrq.zeroxng.Nfir1=50;                  %The order of the FIR low-pass filter
        Metric_param.cardfrq.HR_Fl=1.5;                         %The lower limit of the heart rate band (in Hz)
        Metric_param.cardfrq.HR_Fh=4.0;                         %The higher limit of the heart rate band (in Hz)
        Metric_param.cardfrq.Nf=Metric_param.sig2noi.NfPPG;
        Metric_param.cardfrq.Navg=Metric_param.sig2noi.NavgPPG;
        Metric_param.cardfrq.Nhmx=Metric_param.sig2noi.NfPPG;
        Metric_param.cardfrq.zeroxng.Fl=4*1.5;                  %The cut-off freq (Hz) of the low-pass filter
        Metric_param.cardfrq.zeroxng.Nfir1=50;                  %The order of the FIR low-pass filter
        Metric_param.resppwr.Np=51;
        Metric_param.resppwr.Nq=[];
        Metric_param.resppwr.QB= [0.4 2] % Frequency band for quiet breathing 
        Metric_param.br2mvpw.Nm=251;
        Metric_param.rootmsq.Nr=Metric_param.br2mvpw.Nm;
        Metric_param.taphase.Na=251;
        Metric_param.sigbrea.Nb=101;
        Metric_param.sigbrea.Nmu1=Metric_param.sigbrea.Nb;
        Metric_param.sigbrea.Navg=21;
        Metric_param.nppnorm.Nt_PPG=21;
        Metric_param.nppnorm.Nt_RIP=71;
        Metric_param.nppnorm.Nm=251;
        Metric_param.nppnorm.Nq=10*60*Fs+1; % Number of samples to use for normalization of nonperiodic breathing metirc 
        Metric_param.nppnorm.Q=0.1;
        Metric_param.nppnorm.No=Metric_param.nppnorm.Nq-2*Fs;
        Metric_param.nppnorm.Normalize=true;
        Metric_param.varnorm.Np=Metric_param.resppwr.Np;
        Metric_param.varnorm.Nm=251;
        Metric_param.varnorm.Nq=2*60*Fs+1;  % Number of sample to use for normalization of variance
        Metric_param.varnorm.Q=0.5;
        Metric_param.varnorm.No=Metric_param.varnorm.Nq-2*Fs;
        Metric_param.xcor.Nx=251;
        Metric_param.voleffi.Nv=251;
    end

    %% General variables
    xlen=length(RCG);
    BreathFreqs=[0.1:0.15:1.9]';
    
    %% Store MetricMetadata
    MetricMetadata.Metric_param=Metric_param;
    MetricMetadata.usedRCG=~isempty(RCG);
    MetricMetadata.usedABD=~isempty(ABD);
    MetricMetadata.usedPPG=~isempty(PPG);
    MetricMetadata.usedSAT=~isempty(SAT);
    MetricMetadata.usedECG=~isempty(ECG);
    MetricMetadata.Denoise=Denoise;
    MetricMetadata.Fs=Fs;
    MetricMetadata.DateEstimated=now;
    
    %% Define Metrics and set them to NaN
    Metrics.resppwr_RCGxxx_win2sid=nan(xlen,1); %Normalized power on breathing band RCG. Old prc.
    Metrics.resppwr_ABDxxx_win2sid=nan(xlen,1); %Normalized power on breathing band ABD. Old pab.
    Metrics.br2mvpw_RCGxxx_filtbnk=nan(xlen,1); %Comparison of powers in artifact and breathing bands RCG. Old mrc.
    Metrics.br2mvpw_ABDxxx_filtbnk=nan(xlen,1); %Comparison of powers in artifact and breathing bands ABD. Old mab.
    Metrics.taphase_RCGABD_bpbinsg=nan(xlen,1); %Thoracoabdominal phase using band-pass filter. Old phi.
    Metrics.rootmsq_RCGxxx_win2sid=nan(xlen,1); %RMS of RCG.
    Metrics.rootmsq_ABDxxx_win2sid=nan(xlen,1); %RMS of ABD.
    Metrics.rootmsq_RCGABD_win2sid=nan(xlen,1); %Sum of RMS of RCG and ABD. Old rms.
    Metrics.respfrq_ABDxxx_filtbnk=nan(xlen,1); %Respiratory frequency using filter bank. Old fmx.
    Metrics.cardfrq_PPGxxx_filtbnk=nan(xlen,1); %Cardiac frequency from PPG using filter bank. Old hmx.
    Metrics.cardfrq_ECGxxx_filtbnk=nan(xlen,1); %Cardiac frequency from ECG using filter bank. Old hmx.
    Metrics.respfrq_RCGxxx_zeroxng=nan(xlen,1); %Respiratory frequency in RCG using zero crossings. Old frm.
    Metrics.raisfrq_RCGxxx_zeroxng=nan(xlen,1); %Inspiratory frequency in RCG using zero crossings. Old fri.
    Metrics.fallfrq_RCGxxx_zeroxng=nan(xlen,1); %Expiratory frequency in RCG using zero crossings. Old fre.
    Metrics.respfrq_ABDxxx_zeroxng=nan(xlen,1); %Respiratory frequency in ABD using zero crossings. Old fam.
    Metrics.raisfrq_ABDxxx_zeroxng=nan(xlen,1); %Inspiratory frequency in ABD using zero crossings. Old fai.
    Metrics.fallfrq_ABDxxx_zeroxng=nan(xlen,1); %Expiratory frequency in ABD using zero crossings. Old fae.
    Metrics.cardfrq_PPGxxx_zeroxng=nan(xlen,1); %Cardiac frequency from PPG using zero crossings. Old fpm.
    Metrics.raisfrq_PPGxxx_zeroxng=nan(xlen,1); %Rising edge frequency in PPG using zero crossings. Old fpr.
    Metrics.fallfrq_PPGxxx_zeroxng=nan(xlen,1); %Falling edge frequency in PPG using zero crossings. Old fpf.
    Metrics.sigbrea_RCGxxx_dtbinsg=nan(xlen,1); %Breathing metric from RCG. Old brc.
    Metrics.sigbrea_ABDxxx_dtbinsg=nan(xlen,1); %Breathing metric from ABD. Old bab.
    Metrics.sumbrea_RCGABD_dtbinsg=nan(xlen,1); %Synchronous breathing metric. Old bsu.
    Metrics.difbrea_RCGABD_dtbinsg=nan(xlen,1); %Asynchronous breathing metric. Old bdi.
    Metrics.taphase_RCGABD_dtbinsg=nan(xlen,1); %Thoracoabdominal phase reducing trends. Old bph.
    Metrics.nppnorm_RCGxxx_win2sid=nan(xlen,1); %Normalized non-periodic power in RCG. Old npr.
    Metrics.nppnorm_ABDxxx_win2sid=nan(xlen,1); %Normalized non-periodic power in ABD. Old npa.
    Metrics.nppnorm_PPGxxx_win2sid=nan(xlen,1); %Normalized non-periodic power in PPG. Old npp.
    Metrics.varnorm_RCGxxx_win2sid=nan(xlen,1); %Normalized variance of RCG. Old vrc.
    Metrics.varnorm_ABDxxx_win2sid=nan(xlen,1); %Normalized variance of ABD. Old vab.
    Metrics.xcorp00_RCGABD_win2sid=nan(xlen,1); %Cross-correlation-coefficient between RCG and ABD. Old rra.
    Metrics.xcorp00_RCGPPG_win2sid=nan(xlen,1); %Cross-correlation-coefficient between RCG and PPG. Old rrp.
    Metrics.xcorp00_ABDPPG_win2sid=nan(xlen,1); %Cross-correlation-coefficient between ABD and PPG. Old rap.
    Metrics.xcorp00_RAZCPZ_win2sid=nan(xlen,1); %Cross-correlation-coefficient between respiratory frequency and cardiac frequency from zero-crossings estimates. Old rfz.
    Metrics.xcorp00_RAFCPF_win2sid=nan(xlen,1); %Cross-correlation-coefficient between respiratory frequency and cardiac frequency (PPG) from filter bank estimates. Old rxz.
    Metrics.xcorp00_RAFCEF_win2sid=nan(xlen,1); %Cross-correlation-coefficient between respiratory frequency and cardiac frequency (ECG) from filter bank estimates. Old rxz.
    Metrics.xcorp00_RAZSAT_win2sid=nan(xlen,1); %Cross-correlation-coefficient between SAT and respiratory rate from zero-crossings estimates. Old rsz.
    Metrics.xcorp00_RAFSAT_win2sid=nan(xlen,1); %Cross-correlation-coefficient between SAT and respiratory rate from filter bank estimates. Old rsx.
    Metrics.sig2noi_RCGxxx_adpfilt=nan(xlen,1); %SNR of RCG. Old snr.
    Metrics.sig2noi_ABDxxx_adpfilt=nan(xlen,1); %SNR of ABD. Old sna.
    Metrics.sig2noi_PPGxxx_adpfilt=nan(xlen,1); %SNR of PPG. Old snp.
    Metrics.effevol_RCGABD_win2sid=nan(xlen,1); %Standardized effective volume
    Metrics.obstvol_RCGABD_win2sid=nan(xlen,1); %Standardized obstructed volume
    Metrics.ef2obpw_RCGABD_win2sid=nan(xlen,1); %Ratio of powers of effective and obstructed volumes
    Metrics.voleffi_RCGABD_win2sid=nan(xlen,1); %Respiratory volume efficiency
    
    whichMetrics=fields(Metrics);
    numMetrics=size(whichMetrics,1);

    %% Check for NaNs and recursively split the call
    ixNaN=zeros(xlen,1);
    if ~isempty(RCG)
        ixNaN=ixNaN+isnan(RCG);
    end
    if ~isempty(ABD)
        ixNaN=ixNaN+isnan(ABD);
    end
    if ~isempty(PPG)
        ixNaN=ixNaN+isnan(PPG);
    end
    if ~isempty(SAT)
        ixNaN=ixNaN+isnan(SAT);
    end
    if ~isempty(ECG)
        ixNaN=ixNaN+isnan(ECG);
    end
    
    if sum(ixNaN)>0     %If there are NaNs, split into segments and make recursive call
        verbose('There are NaNs in the data',ShowMsgs);
        verbose('    ... splitting into segments and making recursive calls ...',ShowMsgs);
        
        %Identify segments without NaNs
        goodSegms=signal2events(ixNaN);
        goodSegms=goodSegms(goodSegms(:,3)==0,:);
        numSegms=size(goodSegms,1);
        
        %Make recursive calls to estimate the metrics for the segments
        for ixSegm=1:numSegms
            segmentIndices=goodSegms(ixSegm,1):goodSegms(ixSegm,2);
            myRCG=[];
            if ~isempty(RCG)
                myRCG=RCG(segmentIndices);
            end
            myABD=[];
            if ~isempty(ABD)
                myABD=ABD(segmentIndices);
            end
            myPPG=[];
            if ~isempty(PPG)
                myPPG=PPG(segmentIndices);
            end
            mySAT=[];
            if ~isempty(SAT)
                mySAT=SAT(segmentIndices);
            end
            myECG=[];
            if ~isempty(ECG)
                myECG=ECG(segmentIndices);
            end
            SegmMetrics=CardiorespiratoryMetrics(myRCG,myABD,myPPG,mySAT,myECG,Metric_param,Denoise,Fs,ShowMsgs);
            
            for ixMetric=1:numMetrics
                Metrics.(whichMetrics{ixMetric})(segmentIndices)=SegmMetrics.(whichMetrics{ixMetric});
            end
        end
    else                %Else estimate the metrics for the segment
        verbose('Estimating metrics ...',ShowMsgs);
        
        %% SNR
        tic;
        verbose([char(9) 'SNR ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.sig2noi.NfPPG Metric_param.sig2noi.NavgPPG Metric_param.sig2noi.NfRIP Metric_param.sig2noi.NavgRIP Metric_param.sig2noi.M Metric_param.sig2noi.Nsnr])+1;
        if ~isempty(PPG) && ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            [bR,aR]=butter(5,[0.4 2]/(Fs/2));
            auxfR=freqStat(filtfilt(bR,aR,ABD),Metric_param.sig2noi.NfRIP,Metric_param.sig2noi.NavgRIP,1,Fs);
            auxfR(auxfR>6)=6;

            %Estimate HR
            [bC,aC]=butter(5,[1.5 4]/(Fs/2));
            auxfC=freqStat(filtfilt(bC,aC,PPG),Metric_param.sig2noi.NfPPG,Metric_param.sig2noi.NavgPPG,1,Fs);
            auxfC(auxfC>12)=12;

            %Get SNR
            [SIGNAL,NOISE,~,~,~,Tau]=estimateSignalVSNoise(RCG,ABD,PPG,auxfR,Metric_param.sig2noi.MaxH_fR,auxfC,Metric_param.sig2noi.MaxH_fC,Metric_param.sig2noi.M,Metric_param.sig2noi.Mu,Metric_param.sig2noi.epsilon,Fs);
            clear bR aR bC aC auxfR auxfC
            nconv=ceil(-Tau*log(Metric_param.sig2noi.epsilon)); %Samples needed for convergence

            if nconv<xlen
                auxRCs=SIGNAL(:,1);
                auxABs=SIGNAL(:,2);
                auxPPs=SIGNAL(:,3);
                auxRCs(1:nconv(1))=nan;
                auxABs(1:nconv(2))=nan;
                auxPPs(1:nconv(3))=nan;
                if Denoise
                    RCG=auxRCs;
                    ABD=auxABs;
                    PPG=auxPPs;
                end
                auxRCs=auxRCs-nanmean(auxRCs);
                auxABs=auxABs-nanmean(auxABs);
                auxPPs=auxPPs-nanmean(auxPPs);
                auxRCn=NOISE(:,1);
                auxABn=NOISE(:,2);
                auxPPn=NOISE(:,3);
                auxRCn(1:nconv(1))=nan;
                auxABn(1:nconv(2))=nan;
                auxPPn(1:nconv(3))=nan;
                auxRCn=auxRCn-nanmean(auxRCn);
                auxABn=auxABn-nanmean(auxABn);
                auxPPn=auxPPn-nanmean(auxPPn);
                b=ones(Metric_param.sig2noi.Nsnr,1)./Metric_param.sig2noi.Nsnr;
                Metrics.sig2noi_RCGxxx_adpfilt=10.*log10(filter2S(b,auxRCs.^2)./filter2S(b,auxRCn.^2));
                Metrics.sig2noi_ABDxxx_adpfilt=10.*log10(filter2S(b,auxABs.^2)./filter2S(b,auxABn.^2));
                Metrics.sig2noi_PPGxxx_adpfilt=10.*log10(filter2S(b,auxPPs.^2)./filter2S(b,auxPPn.^2));
            end
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Respiratory and Cardiac Frequencies using Zero-Crossings
        tic;
        verbose([char(9) 'Respiratory and Cardiac Frequencies using Zero-Crossings ...'],ShowMsgs);
        
        Wn_respfrq=Metric_param.respfrq.zeroxng.Fl/(Fs/2);
        b_respfrq=fir1(Metric_param.respfrq.zeroxng.Nfir1,Wn_respfrq)';
        Wn_cardfrq=Metric_param.cardfrq.zeroxng.Fl/(Fs/2);
        b_cardfrq=fir1(Metric_param.cardfrq.zeroxng.Nfir1,Wn_cardfrq)';

        clear minXlen;
        minXlen=max([Metric_param.respfrq.Nf Metric_param.respfrq.Navg Metric_param.respfrq.zeroxng.Nfir1])+1;
        if ~isempty(RCG) && xlen>=minXlen
            [arespfrq_RCGxxx_zeroxng,araisfrq_RCGxxx_zeroxng,afallfrq_RCGxxx_zeroxng]=freqStat(RCG,Metric_param.respfrq.Nf,Metric_param.respfrq.Navg,1,Fs);
            arespfrq_RCGxxx_zeroxng(arespfrq_RCGxxx_zeroxng>6)=6;
            araisfrq_RCGxxx_zeroxng(araisfrq_RCGxxx_zeroxng>6)=6;
            afallfrq_RCGxxx_zeroxng(afallfrq_RCGxxx_zeroxng>6)=6;
            arespfrq_RCGxxx_zeroxng(1:sum(isnan(RCG))+floor(Metric_param.respfrq.Nf/2))=nan;
            arespfrq_RCGxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            araisfrq_RCGxxx_zeroxng(1:sum(isnan(RCG))+floor(Metric_param.respfrq.Nf/2))=nan;
            araisfrq_RCGxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            afallfrq_RCGxxx_zeroxng(1:sum(isnan(RCG))+floor(Metric_param.respfrq.Nf/2))=nan;
            afallfrq_RCGxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            Metrics.respfrq_RCGxxx_zeroxng=filter2S(b_respfrq,arespfrq_RCGxxx_zeroxng);
            Metrics.raisfrq_RCGxxx_zeroxng=filter2S(b_respfrq,araisfrq_RCGxxx_zeroxng);
            Metrics.fallfrq_RCGxxx_zeroxng=filter2S(b_respfrq,afallfrq_RCGxxx_zeroxng);
        end

        clear minXlen;
        minXlen=max([Metric_param.respfrq.Nf Metric_param.respfrq.Navg Metric_param.respfrq.zeroxng.Nfir1])+1;
        if ~isempty(ABD) && xlen>=minXlen
            [arespfrq_ABDxxx_zeroxng,araisfrq_ABDxxx_zeroxng,afallfrq_ABDxxx_zeroxng]=freqStat(ABD,Metric_param.respfrq.Nf,Metric_param.respfrq.Navg,1,Fs);
            arespfrq_ABDxxx_zeroxng(arespfrq_ABDxxx_zeroxng>6)=6;
            araisfrq_ABDxxx_zeroxng(araisfrq_ABDxxx_zeroxng>6)=6;
            afallfrq_ABDxxx_zeroxng(afallfrq_ABDxxx_zeroxng>6)=6;
            arespfrq_ABDxxx_zeroxng(1:sum(isnan(ABD))+floor(Metric_param.respfrq.Nf/2))=nan;
            arespfrq_ABDxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            araisfrq_ABDxxx_zeroxng(1:sum(isnan(ABD))+floor(Metric_param.respfrq.Nf/2))=nan;
            araisfrq_ABDxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            afallfrq_ABDxxx_zeroxng(1:sum(isnan(ABD))+floor(Metric_param.respfrq.Nf/2))=nan;
            afallfrq_ABDxxx_zeroxng(end-floor(Metric_param.respfrq.Nf/2):end)=nan;
            Metrics.respfrq_ABDxxx_zeroxng=filter2S(b_respfrq,arespfrq_ABDxxx_zeroxng);
            Metrics.raisfrq_ABDxxx_zeroxng=filter2S(b_respfrq,araisfrq_ABDxxx_zeroxng);
            Metrics.fallfrq_ABDxxx_zeroxng=filter2S(b_respfrq,afallfrq_ABDxxx_zeroxng);
        end

        clear minXlen;
        minXlen=max([Metric_param.cardfrq.Nf Metric_param.cardfrq.Navg Metric_param.cardfrq.zeroxng.Nfir1])+1;
        if ~isempty(PPG) && xlen>=minXlen
            [acardfrq_PPGxxx_zeroxng,araisfrq_PPGxxx_zeroxng,afallfrq_PPGxxx_zeroxng]=freqStat(PPG,Metric_param.cardfrq.Nf,Metric_param.cardfrq.Navg,1,Fs);
            acardfrq_PPGxxx_zeroxng(acardfrq_PPGxxx_zeroxng>12)=12;
            araisfrq_PPGxxx_zeroxng(araisfrq_PPGxxx_zeroxng>12)=12;
            afallfrq_PPGxxx_zeroxng(afallfrq_PPGxxx_zeroxng>12)=12;
            acardfrq_PPGxxx_zeroxng(1:sum(isnan(PPG))+floor(Metric_param.cardfrq.Nf/2))=nan;
            acardfrq_PPGxxx_zeroxng(end-floor(Metric_param.cardfrq.Nf/2):end)=nan;
            araisfrq_PPGxxx_zeroxng(1:sum(isnan(PPG))+floor(Metric_param.cardfrq.Nf/2))=nan;
            araisfrq_PPGxxx_zeroxng(end-floor(Metric_param.cardfrq.Nf/2):end)=nan;
            afallfrq_PPGxxx_zeroxng(1:sum(isnan(PPG))+floor(Metric_param.cardfrq.Nf/2))=nan;
            afallfrq_PPGxxx_zeroxng(end-floor(Metric_param.cardfrq.Nf/2):end)=nan;
            Metrics.cardfrq_PPGxxx_zeroxng=filter2S(b_cardfrq,acardfrq_PPGxxx_zeroxng);
            Metrics.raisfrq_PPGxxx_zeroxng=filter2S(b_cardfrq,araisfrq_PPGxxx_zeroxng);
            Metrics.fallfrq_PPGxxx_zeroxng=filter2S(b_cardfrq,afallfrq_PPGxxx_zeroxng);
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Original 7 AUREA metrics
        tic;
        verbose([char(9) 'Original 7 AUREA metrics ...'],ShowMsgs);
        
        [b1,a1] = cheby1(6,0.1,[0.0825]/(Fs/2),'high');

        clear minXlen;
        minXlen=max([Metric_param.resppwr.Np Metric_param.resppwr.Nq])+1;
        if ~isempty(RCG) && xlen>=minXlen
            ixGood=~isnan(RCG);
            [aresppwr_RCGxxx_win2sid]=pauseStat(filtfilt(b1,a1,RCG(ixGood)),Metric_param.resppwr.Np,Metric_param.resppwr.Nq,Fs);
            if ~isempty(Metric_param.resppwr.Nq)
                aresppwr_RCGxxx_win2sid(1:Metric_param.resppwr.Nq-1+floor(Metric_param.resppwr.Np/2))=nan;
                aresppwr_RCGxxx_win2sid(end-floor(Metric_param.resppwr.Np/2):end)=nan;
            else
                aresppwr_RCGxxx_win2sid(1:floor(Metric_param.resppwr.Np/2))=nan;
                aresppwr_RCGxxx_win2sid(end-floor(Metric_param.resppwr.Np/2):end)=nan;
            end
            Metrics.resppwr_RCGxxx_win2sid(ixGood)=aresppwr_RCGxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.resppwr.Np Metric_param.resppwr.Nq])+1;
        if ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(ABD);
            [aresppwr_ABDxxx_win2sid]=pauseStat(filtfilt(b1,a1,ABD(ixGood)),Metric_param.resppwr.Np,Metric_param.resppwr.Nq,Fs);
            if ~isempty(Metric_param.resppwr.Nq)
                aresppwr_ABDxxx_win2sid(1:Metric_param.resppwr.Nq-1+floor(Metric_param.resppwr.Np/2))=nan;
                aresppwr_ABDxxx_win2sid(end-floor(Metric_param.resppwr.Np/2):end)=nan;
            else
                aresppwr_ABDxxx_win2sid(1:floor(Metric_param.resppwr.Np/2))=nan;
                aresppwr_ABDxxx_win2sid(end-floor(Metric_param.resppwr.Np/2):end)=nan;
            end
            Metrics.resppwr_ABDxxx_win2sid(ixGood)=aresppwr_ABDxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.br2mvpw.Nm])+1;
        if ~isempty(RCG) && xlen>=minXlen
            ixGood=~isnan(RCG);
            [abr2mvpw_RCGxxx_filtbnk]=mvtStat(filtfilt(b1,a1,RCG(ixGood)),Metric_param.br2mvpw.Nm,Fs);
            abr2mvpw_RCGxxx_filtbnk(1:floor(Metric_param.br2mvpw.Nm/2))=nan;
            abr2mvpw_RCGxxx_filtbnk(end-floor(Metric_param.br2mvpw.Nm/2):end)=nan;
            Metrics.br2mvpw_RCGxxx_filtbnk(ixGood)=abr2mvpw_RCGxxx_filtbnk;
        end

        clear minXlen;
        minXlen=max([Metric_param.br2mvpw.Nm])+1;
        if ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(ABD);
            [abr2mvpw_ABDxxx_filtbnk]=mvtStat(filtfilt(b1,a1,ABD(ixGood)),Metric_param.br2mvpw.Nm,Fs);
            abr2mvpw_ABDxxx_filtbnk(1:floor(Metric_param.br2mvpw.Nm/2))=nan;
            abr2mvpw_ABDxxx_filtbnk(end-floor(Metric_param.br2mvpw.Nm/2):end)=nan;
            Metrics.br2mvpw_ABDxxx_filtbnk(ixGood)=abr2mvpw_ABDxxx_filtbnk;
        end

        clear minXlen;
        minXlen=max([Metric_param.rootmsq.Nr])+1;
        if ~isempty(RCG) && xlen>=minXlen
            ixGood=~isnan(RCG);
            [arootmsq_RCGxxx_win2sid]=rmsStat(RCG(ixGood),RCG(ixGood),Metric_param.rootmsq.Nr)./2;
            arootmsq_RCGxxx_win2sid(1:floor(Metric_param.rootmsq.Nr/2))=nan;
            arootmsq_RCGxxx_win2sid(end-floor(Metric_param.rootmsq.Nr/2):end)=nan;
            Metrics.rootmsq_RCGxxx_win2sid(ixGood)=arootmsq_RCGxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.rootmsq.Nr])+1;
        if ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(ABD);
            [arootmsq_ABDxxx_win2sid]=rmsStat(ABD(ixGood),ABD(ixGood),Metric_param.rootmsq.Nr)./2;
            arootmsq_ABDxxx_win2sid(1:floor(Metric_param.rootmsq.Nr/2))=nan;
            arootmsq_ABDxxx_win2sid(end-floor(Metric_param.rootmsq.Nr/2):end)=nan;
            Metrics.rootmsq_ABDxxx_win2sid(ixGood)=arootmsq_ABDxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.rootmsq.Nr])+1;
        if ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(RCG) & ~isnan(ABD);
            [arootmsq_RCGABD_win2sid]=rmsStat(RCG(ixGood),ABD(ixGood),Metric_param.rootmsq.Nr);
            arootmsq_RCGABD_win2sid(1:floor(Metric_param.rootmsq.Nr/2))=nan;
            arootmsq_RCGABD_win2sid(end-floor(Metric_param.rootmsq.Nr/2):end)=nan;
            Metrics.rootmsq_RCGABD_win2sid(ixGood)=arootmsq_RCGABD_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.taphase.Na])+1;
        if ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(RCG) & ~isnan(ABD);
            [ataphase_RCGABD_bpbinsg,arespfrq_ABDxxx_filtbnk]=asynchStat(filtfilt(b1,a1,RCG(ixGood)),filtfilt(b1,a1,ABD(ixGood)),Metric_param.taphase.Na,Fs);
            ataphase_RCGABD_bpbinsg(1:floor(Metric_param.taphase.Na/2))=nan;
            ataphase_RCGABD_bpbinsg(end-floor(Metric_param.taphase.Na/2):end)=nan;
            arespfrq_ABDxxx_filtbnk=BreathFreqs(arespfrq_ABDxxx_filtbnk);
            arespfrq_ABDxxx_filtbnk(1:floor(Metric_param.taphase.Na/2))=nan;
            arespfrq_ABDxxx_filtbnk(end-floor(Metric_param.taphase.Na/2):end)=nan;
            Metrics.taphase_RCGABD_bpbinsg(ixGood)=ataphase_RCGABD_bpbinsg;
            Metrics.respfrq_ABDxxx_filtbnk(ixGood)=arespfrq_ABDxxx_filtbnk;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Breathing statistics
        tic;
        verbose([char(9) 'Breathing statistics ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.sigbrea.Nb Metric_param.sigbrea.Nmu1 Metric_param.sigbrea.Navg])+1;
        if ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(RCG) & ~isnan(ABD);
            [asigbrea_RCGxxx_dtbinsg,asigbrea_ABDxxx_dtbinsg,asumbrea_RCGABD_dtbinsg,adifbrea_RCGABD_dtbinsg,ataphase_RCGABD_dtbinsg]= ...
                breathStat(RCG(ixGood),ABD(ixGood),Metric_param.sigbrea.Nb,Metric_param.sigbrea.Nmu1,Metric_param.sigbrea.Navg,Fs);
            asigbrea_RCGxxx_dtbinsg(1:floor(Metric_param.sigbrea.Nb/2))=nan;
            asigbrea_RCGxxx_dtbinsg(end-floor(Metric_param.sigbrea.Nb/2):end)=nan;
            asigbrea_ABDxxx_dtbinsg(1:floor(Metric_param.sigbrea.Nb/2))=nan;
            asigbrea_ABDxxx_dtbinsg(end-floor(Metric_param.sigbrea.Nb/2):end)=nan;
            asumbrea_RCGABD_dtbinsg(1:floor(Metric_param.sigbrea.Nb/2))=nan;
            asumbrea_RCGABD_dtbinsg(end-floor(Metric_param.sigbrea.Nb/2):end)=nan;
            adifbrea_RCGABD_dtbinsg(1:floor(Metric_param.sigbrea.Nb/2))=nan;
            adifbrea_RCGABD_dtbinsg(end-floor(Metric_param.sigbrea.Nb/2):end)=nan;
            ataphase_RCGABD_dtbinsg(1:floor(Metric_param.sigbrea.Nb/2))=nan;
            ataphase_RCGABD_dtbinsg(end-floor(Metric_param.sigbrea.Nb/2):end)=nan;
            Metrics.sigbrea_RCGxxx_dtbinsg(ixGood)=asigbrea_RCGxxx_dtbinsg;
            Metrics.sigbrea_ABDxxx_dtbinsg(ixGood)=asigbrea_ABDxxx_dtbinsg;
            Metrics.sumbrea_RCGABD_dtbinsg(ixGood)=asumbrea_RCGABD_dtbinsg;
            Metrics.difbrea_RCGABD_dtbinsg(ixGood)=adifbrea_RCGABD_dtbinsg;
            Metrics.taphase_RCGABD_dtbinsg(ixGood)=ataphase_RCGABD_dtbinsg;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Non-periodic power
        tic;
        verbose([char(9) 'Non-periodic power ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.nppnorm.Nt_RIP Metric_param.nppnorm.Nm Metric_param.nppnorm.Nq])+1;
        if ~isempty(RCG) && xlen>=minXlen
            ixGood=~isnan(RCG);
            [anppnorm_RCGxxx_win2sid]=amplStat(RCG(ixGood),Metric_param.nppnorm.Nt_RIP,Metric_param.nppnorm.Nm,Metric_param.nppnorm.Nq,Metric_param.nppnorm.Q,Metric_param.nppnorm.No,Metric_param.nppnorm.Normalize,Fs);
            anppnorm_RCGxxx_win2sid(1:floor(Metric_param.nppnorm.Nm/2))=nan;
            anppnorm_RCGxxx_win2sid(end-floor(Metric_param.nppnorm.Nm/2):end)=nan;
            Metrics.nppnorm_RCGxxx_win2sid(ixGood)=anppnorm_RCGxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.nppnorm.Nt_RIP Metric_param.nppnorm.Nm Metric_param.nppnorm.Nq])+1;
        if ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(ABD);
            [anppnorm_ABDxxx_win2sid]=amplStat(ABD(ixGood),Metric_param.nppnorm.Nt_RIP,Metric_param.nppnorm.Nm,Metric_param.nppnorm.Nq,Metric_param.nppnorm.Q,Metric_param.nppnorm.No,Metric_param.nppnorm.Normalize,Fs);
            anppnorm_ABDxxx_win2sid(1:floor(Metric_param.nppnorm.Nm/2))=nan;
            anppnorm_ABDxxx_win2sid(end-floor(Metric_param.nppnorm.Nm/2):end)=nan;
            Metrics.nppnorm_ABDxxx_win2sid(ixGood)=anppnorm_ABDxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.nppnorm.Nt_PPG Metric_param.nppnorm.Nm Metric_param.nppnorm.Nq])+1;
        if ~isempty(PPG) && xlen>=minXlen
            ixGood=~isnan(PPG);
            [anppnorm_PPGxxx_win2sid]=amplStat(PPG(ixGood),Metric_param.nppnorm.Nt_PPG,Metric_param.nppnorm.Nm,Metric_param.nppnorm.Nq,Metric_param.nppnorm.Q,Metric_param.nppnorm.No,Metric_param.nppnorm.Normalize,Fs);
            anppnorm_PPGxxx_win2sid(1:floor(Metric_param.nppnorm.Nm/2))=nan;
            anppnorm_PPGxxx_win2sid(end-floor(Metric_param.nppnorm.Nm/2):end)=nan;
            Metrics.nppnorm_PPGxxx_win2sid(ixGood)=anppnorm_PPGxxx_win2sid;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Normalized variance
        tic;
        verbose([char(9) 'Normalized variance ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.varnorm.Np Metric_param.varnorm.Nm Metric_param.varnorm.Nq])+1;
        if ~isempty(RCG) && xlen>=minXlen
            ixGood=~isnan(RCG);
            [avarnorm_RCGxxx_win2sid]=varStat(RCG(ixGood),Metric_param.varnorm.Np,Metric_param.varnorm.Nm,Metric_param.varnorm.Nq,Metric_param.varnorm.Q,Metric_param.varnorm.No,Fs);
            avarnorm_RCGxxx_win2sid(1:floor(Metric_param.varnorm.Nm/2))=nan;
            avarnorm_RCGxxx_win2sid(end-floor(Metric_param.varnorm.Nm/2):end)=nan;
            Metrics.varnorm_RCGxxx_win2sid(ixGood)=avarnorm_RCGxxx_win2sid;
        end

        clear minXlen;
        minXlen=max([Metric_param.varnorm.Np Metric_param.varnorm.Nm Metric_param.varnorm.Nq])+1;
        if ~isempty(ABD) && xlen>=minXlen
            ixGood=~isnan(ABD);
            [avarnorm_ABDxxx_win2sid]=varStat(ABD(ixGood),Metric_param.varnorm.Np,Metric_param.varnorm.Nm,Metric_param.varnorm.Nq,Metric_param.varnorm.Q,Metric_param.varnorm.No,Fs);
            avarnorm_ABDxxx_win2sid(1:floor(Metric_param.varnorm.Nm/2))=nan;
            avarnorm_ABDxxx_win2sid(end-floor(Metric_param.varnorm.Nm/2):end)=nan;
            Metrics.varnorm_ABDxxx_win2sid(ixGood)=avarnorm_ABDxxx_win2sid;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Cardiac frequency based on filter bank (hmx)
        tic;
        verbose([char(9) 'Cardiac frequency based on filter bank ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.cardfrq.Nhmx])+1;
        
        HR_Freqs.Fl=Metric_param.cardfrq.HR_Fl;
        HR_Freqs.Fh=Metric_param.cardfrq.HR_Fh;
        
        if ~isempty(PPG) && xlen>=minXlen
            ixGood=~isnan(PPG);
            [~,~,~,~,acardfrq_PPGxxx_filtbnk]=filtBankCardiac(PPG(ixGood),Metric_param.cardfrq.Nhmx,HR_Freqs,[],Fs);
            acardfrq_PPGxxx_filtbnk(1:floor(Metric_param.cardfrq.Nhmx/2))=nan;
            acardfrq_PPGxxx_filtbnk(end-floor(Metric_param.cardfrq.Nhmx/2):end)=nan;
            Metrics.cardfrq_PPGxxx_filtbnk(ixGood)=acardfrq_PPGxxx_filtbnk;
        end
        
        clear minXlen;
        minXlen=max([Metric_param.cardfrq.Nhmx])+1;
        if ~isempty(ECG) && xlen>=minXlen
            ixGood=~isnan(ECG);
            [~,~,~,~,acardfrq_ECGxxx_filtbnk]=filtBankCardiac(ECG(ixGood),Metric_param.cardfrq.Nhmx,HR_Freqs,[],Fs);
            acardfrq_ECGxxx_filtbnk(1:floor(Metric_param.cardfrq.Nhmx/2))=nan;
            acardfrq_ECGxxx_filtbnk(end-floor(Metric_param.cardfrq.Nhmx/2):end)=nan;
            Metrics.cardfrq_ECGxxx_filtbnk(ixGood)=acardfrq_ECGxxx_filtbnk;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);

        %% Cross-correlation-coefficient
        tic;
        verbose([char(9) 'Cross-correlation-coefficient ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            s1=RCG;
            s2=ABD;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RCGABD_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isempty(RCG) && ~isempty(PPG) && xlen>=minXlen
            s1=RCG;
            s2=PPG;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RCGPPG_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isempty(ABD) && ~isempty(PPG) && xlen>=minXlen
            s1=ABD;
            s2=PPG;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_ABDPPG_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isnan(nanmean(Metrics.respfrq_ABDxxx_zeroxng)) && ~isnan(nanmean(Metrics.cardfrq_PPGxxx_zeroxng)) && xlen>=minXlen
            s1=Metrics.respfrq_ABDxxx_zeroxng;
            s2=Metrics.cardfrq_PPGxxx_zeroxng;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RAZCPZ_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isnan(nanmean(Metrics.respfrq_ABDxxx_filtbnk)) && ~isnan(nanmean(Metrics.cardfrq_PPGxxx_filtbnk)) && xlen>=minXlen
            s1=Metrics.respfrq_ABDxxx_filtbnk;
            s2=Metrics.cardfrq_PPGxxx_filtbnk;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RAFCPF_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isnan(nanmean(Metrics.respfrq_ABDxxx_filtbnk)) && ~isnan(nanmean(Metrics.cardfrq_ECGxxx_filtbnk)) && xlen>=minXlen
            s1=Metrics.respfrq_ABDxxx_filtbnk;
            s2=Metrics.cardfrq_ECGxxx_filtbnk;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RAFCEF_win2sid(ixGood)=arho;
        end

        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isnan(nanmean(Metrics.respfrq_ABDxxx_zeroxng)) && ~isempty(SAT) && xlen>=minXlen
            s1=Metrics.respfrq_ABDxxx_zeroxng;
            s2=SAT;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RAZSAT_win2sid(ixGood)=arho;
        end
        
        clear minXlen;
        minXlen=max([Metric_param.xcor.Nx])+1;
        if ~isnan(nanmean(Metrics.respfrq_ABDxxx_filtbnk)) && ~isempty(SAT) && xlen>=minXlen
            s1=Metrics.respfrq_ABDxxx_filtbnk;
            s2=SAT;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.xcor.Nx,Fs);
            mu2=momStat(s2(ixGood),1,Metric_param.xcor.Nx,Fs);
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.xcor.Nx,Fs));
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.xcor.Nx,Fs));
            arho=filter2S(ones(Metric_param.xcor.Nx,1)./Metric_param.xcor.Nx,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            arho(1:floor(Metric_param.xcor.Nx))=nan;
            arho(end-floor(Metric_param.xcor.Nx):end)=nan;
            Metrics.xcorp00_RAFSAT_win2sid(ixGood)=arho;
        end
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);
        
        %% Respiratory volume efficiency
        tic;
        verbose([char(9) 'Respiratory volume efficiency ...'],ShowMsgs);
        
        clear minXlen;
        minXlen=max([Metric_param.voleffi.Nv])+1;
        if ~isempty(RCG) && ~isempty(ABD) && xlen>=minXlen
            s1=RCG;
            s2=ABD;
            ixGood=~isnan(s1) & ~isnan(s2);
            mu1=momStat(s1(ixGood),1,Metric_param.voleffi.Nv,Fs);
            mu1(1:floor(Metric_param.voleffi.Nv))=nan;
            mu1(end-floor(Metric_param.voleffi.Nv):end)=nan;
            mu2=momStat(s2(ixGood),1,Metric_param.voleffi.Nv,Fs);
            mu2(1:floor(Metric_param.voleffi.Nv))=nan;
            mu2(end-floor(Metric_param.voleffi.Nv):end)=nan;
            sd1=sqrt(momStat(s1(ixGood),2,Metric_param.voleffi.Nv,Fs));
            sd1(1:floor(Metric_param.voleffi.Nv))=nan;
            sd1(end-floor(Metric_param.voleffi.Nv):end)=nan;
            sd2=sqrt(momStat(s2(ixGood),2,Metric_param.voleffi.Nv,Fs));
            sd2(1:floor(Metric_param.voleffi.Nv))=nan;
            sd2(end-floor(Metric_param.voleffi.Nv):end)=nan;

            %Respiratory volume efficiency
            auxr=filter2S(ones(Metric_param.voleffi.Nv,1)./Metric_param.voleffi.Nv,(s1(ixGood)-mu1).*(s2(ixGood)-mu2))./(sd1.*sd2);
            Metrics.voleffi_RCGABD_win2sid(ixGood)=sqrt((1+auxr)./2);
            %Standardized effective volume
            auxK=sd1./sd2;
            auxM=1./(sd1.*sqrt(2*(1+auxr)));
            Metrics.effevol_RCGABD_win2sid(ixGood)=auxM.*(s1+auxK.*s2);
            %Standardized obstructed volume
            Metrics.obstvol_RCGABD_win2sid(ixGood)=-auxM.*(s1-auxK.*s2);
            %Ratio of powers of effective and obstructed volumes
            effePw=filter2S(ones(Metric_param.voleffi.Nv,1)./Metric_param.voleffi.Nv,Metrics.effevol_RCGABD_win2sid(ixGood).^2);
            obstPw=filter2S(ones(Metric_param.voleffi.Nv,1)./Metric_param.voleffi.Nv,Metrics.obstvol_RCGABD_win2sid(ixGood).^2);
            Metrics.ef2obpw_RCGABD_win2sid(ixGood)=effePw./obstPw;
        end
        
        verbose([char(9) '... done (elapsed time ' num2str(toc,'%1.2f') ' s)'],ShowMsgs);
    end
end