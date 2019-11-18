function Metric_param = metricParamInit (Fs)
%metrocParamDefault - initial  Metric_param strucutre with default values

%  
        Metric_param.sig2noi.NfPPG=65;% window length for state
        Metric_param.sig2noi.NavgPPG=11; % length of smooth window 
        Metric_param.sig2noi.NfRIP=251; % widow length
        Metric_param.sig2noi.NavgRIP=25; % length of smoothing window
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
%% Respiratory power estimates         
        Metric_param.resppwr.Np=51; %  length of the sliding window used to compute resppwr
        Metric_param.resppwr.Nq=[]; %$ window length for  real-time (time-varying) normalization of AMP. If Nq=[] the whole record is used
        Metric_param.resppwr.QB= [0.4 2] % Frequency band for quiet breathing 
        Metric_param.br2mvpw.Nm=251; % window length for ratio of breathing to movement power.
        Metric_param.rootmsq.Nr=Metric_param.br2mvpw.Nm;
        Metric_param.taphase.Na=251;
%% Breathing metric paramters used for SYB and ASB
        Metric_param.sigbrea.Nb=101; % window length to estimate breathing power.
        Metric_param.sigbrea.Nmu1=Metric_param.sigbrea.Nb; % window legnth for mean estimation 
        Metric_param.sigbrea.Navg=21; % Smoothing window length
        Metric_param.nppnorm.Nt_PPG=21; % window used to comptue rms values of PPG
 %% Nonperiodic power parameters - used for MOVEMENT
        Metric_param.nppnorm.Nt_RIP=71;  % Period of maximum power for respiration
        Metric_param.nppnorm.Nm=251;%  % window length for estimating local mean and std
        Metric_param.nppnorm.Nq=10*60*Fs+1; % Number of samples to use for normalization of nonperiodic breathing metric
        Metric_param.nppnorm.Q=0.1; % normalization quantile for npnorm
        Metric_param.nppnorm.No=Metric_param.nppnorm.Nq-2*Fs; % number of samples by which successive estimations of the Q-quantile overlap.
        Metric_param.nppnorm.Normalize=true;
        
  %% Parameters for variance metrics  - used for PAU  
        Metric_param.varnorm.Np=Metric_param.resppwr.Np; %  length of the sliding window used to varnorm
        Metric_param.varnorm.Nm=251;  % window length for estimating local mean removed when computing variance
        Metric_param.varnorm.Nq=2*60*Fs+1;  % Window length for estimation of normalization quantile.  
        Metric_param.varnorm.Q=0.5; % quantile for normalization 
        Metric_param.varnorm.No=Metric_param.varnorm.Nq-2*Fs; % number of samples by which successive estimations of the Q-quantile overlap.
  %% Parameter for correlation metrics 
        Metric_param.xcor.Nx=251;
        Metric_param.voleffi.Nv=251;
        
        
        


%% Metric paramters
% FREQ STAT
% Nf is a scalar value with the length (in
%       sample points) of the sliding window.
%   Navg is a scalar value with the length
%       (in sample points) of the smoothing
%       window (for noise reduction).
%   bSmooth is an S-by-1 vector with the coefficients
%       of smoothing FIR filter at the output.


%% pause states
%  Np is a scalar value with the length (in sample points) of the  sliding window.
%  Nq is a scalar value with the length (in sample points) of the  sliding window for the online Quiet Breathing power estimation.
%        If Nq is ommited, then the pause test statistic is computed for the offline version.
%  Fs is a scalar value with the sampling frequency (default=50Hz).
%
%% rms stat
% %   Nr is a scalar value with the length (in sample points) of the
%        sliding window used to comptue rms values 
% %   Nm is a scalar value with the length (in sample points) of the
%      sliding window used to compute movement stats
%% Breathing stats
%  Nb is a scalar value with the length (in sample points) of the sliding window
%      used to estimate the breathing power.
%  Nmu1 is a scalar value with the length (in sample points) of the sliding window  used to estimate the signal's mean.
%  Navg is a scalar value with the length (in sample points) of the smoothing
%      window.
%% amplStat
% %   Nm is a scalar value with the length (in sample points)
%       of the sliding window that estimates
%       the local mean and RMS.
%%   Nq is a scalar value with the length (in sample points)
%       of the sliding window for the real-time
%       (time-varying) normalization of AMP. If Nq is
%       ommited, then the offline version of the
%       statistic is computed.
%%   Q is a scalar value ranging from 0 to 1
%       indicating the normalization quantile.
%   No is a scalar value with the number of samples
%       by which successive estimations of the Q-quantile
%       overlap. Maximum overlap = Nq-1.
%% Variance STATS
% %   Nv is a scalar value with the length (in sample points) of the
%      sliding window.
%   Nq is a scalar value with the length (in sample points) of the
%      sliding window for the online Quiet Breathing power estimation.
%      If Nq is ommited, then the pause test statistic is computed
%      for the offline version.
%% MOMSTAT
%   power is a scalar value indicating the moment's
%       power.
%   Nmu is a scalar value with the length (in sample
%       points) of the sliding window for the
%       computation of Mu.
%
%% SNR params

%  MaxH_fR is a scalar value indicating the maximum
%       harmonic of fR with significant power.
%   fC is an M-by-1 vector with the instantaneous
%       cardiac frequency.
%   MaxH_fC is a scalar value indicating the maximum
%       harmonic of fC with significant power.
%   M is a scalar value with the order of the adaptive
%       LMS filters for estimation of signal components.
%   Mu is a scalar value with the step size parameter
%       of the adaptive LMS filters.
%   epsilon is a scalar value with the maximum average
%       error for convergence of the LMS filters
