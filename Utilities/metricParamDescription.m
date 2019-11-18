function [PDescription] = metricParamDescription(PCodeName)
%metricParamDescription Function outputs  the description of the
%Metric_param entry of interest
%	[ paramTable ] = metricParamTable( Metric_param, Default_param, Fs, ShowTable )
%
%   INPUT
%   PCodeName is a string with the fieldname of the Metric_param entry of interest.
%
%   OUTPUT
%   PDescription is a 1x1 cell containing the description string.
%
%   EXAMPLE
%   [PDescription] = metricParamDescription('resppwr.Np')
%
%   VERSION HISTORY
%   2018_05_17: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%Copyright (c) 2018, Lara J. Kanbar and Robert E. Kearney,
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

switch PCodeName
    case 'sig2noi.NfPPG'
        PDescription ={'Sliding Window for PPG (freqStat).'};
        return;
    case 'sig2noi.NavgPPG'
        PDescription ={'Smoothing window for PPG  for noise reduction (freqStat).'};
        return;
    case 'sig2noi.NfRIP'
        PDescription ={'Sliding window for RIP (freqStat).'};
        return;
    case 'sig2noi.NavgRIP'
        PDescription ={'Smoothing window for RIP for noise reduction (freqStat).'};
        return;
    case 'sig2noi.M'
        PDescription ={'order of the adaptive LMS filters for estimation of signal components (estimateSignalVSNoise).'};
        return;
    case 'sig2noi.Mu'
        PDescription ={'step size parameter of the adaptive LMS filters (estimateSignalVSNoise).'};
        return;
    case 'sig2noi.Nsnr'
        PDescription ={'Length of 2-sided FIR filter.'};
        return;
    case 'sig2noi.MaxH_fR'
        PDescription ={'maximum harmonic of Respiratory frequency with significant power.'};
        return;
    case 'sig2noi.MaxH_fC'
        PDescription ={'maximum harmonic of cardiac frequency with significant power.'};
        return;
    case 'sig2noi.epsilon'
        PDescription ={'maximum average error for convergence of the LMS filters.'};
        return;
    case 'respfrq.Nf'
        PDescription ={'Sliding window for RIP (freqStat).'};
        return;
    case 'respfrq.Navg'
        PDescription ={'Smoothing window for RIP for noise reduction (freqStat).'};
        return;
    case 'cardfrq.Nf'
        PDescription ={'Sliding window for PPG (freqStat).'};
        return;
    case 'cardfrq.Navg'
        PDescription ={'Smoothing window for PPG for noise reduction (freqStat).'};
        return;
    case 'cardfrq.Nhmx'
        PDescription ={'Sliding window for ECG (filtBankCardiac).'};
        return;
    case 'resppwr.Np'
        PDescription ={'length (in sample points) of the sliding window. (pauseStat)'};
        return;
    case 'resppwr.Nq'
        PDescription ={'length of the sliding window for the online Quiet Breathing power estimation. If Nq is ommited, then the pause test statistic is computed for the offline version. (pauseStat)'};
        return;
    case 'br2mvpw.Nm'
        PDescription ={'Sliding window for RIP (mvtStat).'};
        return;
    case 'rootmsq.Nr'
        PDescription ={'length of the sliding window (rmsStat).'};
        return;
    case 'taphase.Na'
        PDescription ={'Sliding window (asynchStat).'};
        return;
    case 'sigbrea.Nb'
        PDescription ={'length of the sliding window used to estimate the breathing power in RIP (breathStat).'};
        return;
    case 'sigbrea.Nmu1'
        PDescription ={'length of the sliding window used to estimate the signal''s mean for RIP (breathStat).'};
        return;
    case 'sigbrea.Navg'
        PDescription ={'Smoothing window (breathStat).'};
        return;
    case 'nppnorm.Nt_PPG'
        PDescription ={'the period corresponding to the frequency with maximum power in the population of input PPG signal (amplStat).'};
        return;
    case 'nppnorm.Nt_RIP'
        PDescription ={'the period corresponding to the frequency with maximum power in the population of input RIP signal (amplStat).'};
        return;
    case 'nppnorm.Normalize'
        PDescription ={'boolean flag indicating whether the output should be normalized by Qth quantile or not (amplStat) .'};
        return;
    case 'nppnorm.Nm'
        PDescription ={'length of the sliding window that estimates the local mean and RMS (amplStat).'};
        return;
    case 'nppnorm.Nq'
        PDescription ={'sliding window for the real-time (time-varying) normalization of AMP. If Nq is ommitted, then the offline version of the statistic is computed (amplStat).'};
        return;
    case 'nppnorm.Q'
        PDescription ={'scalar value ranging from 0 to 1 indicating the normalization quantile. (amplStat)'};
        return;
    case 'nppnorm.No'
        PDescription ={'number of samples by which successive estimations of the Q-quantile overlap. Maximum overlap = Nq-1. (amplStat)'};
        return;
    case 'varnorm.Np'
        PDescription ={'length of the sliding window. (varStat)'};
        return;
    case 'varnorm.Nm'
        PDescription ={'length of the sliding window that estimates the local mean (varStat)'};
        return;
    case 'varnorm.Nq'
        PDescription ={'length of the sliding window for the online Quiet Breathing power estimation. If Nq is ommitted, then the pause test statistic is computed for the offline version. (varStat)'};
        return;
    case 'varnorm.Q'
        PDescription ={'scalar value ranging from 0 to 1 indicating the normalization quantile. (varStat).'};
        return;
    case 'varnorm.No'
        PDescription ={'number of samples by which successive estimations of the Q-quantile overlap. (varStat).'};
        return;
    case 'xcor.Nx'
        PDescription ={'sliding window for the computation of Mu (momStat.'};
        return;
    case 'respfrq.zeroxng.Fl'
        PDescription ={'The cut-off freq (Hz) of the low-pass filter'};
        return;
    case 'respfrq.zeroxng.Nfir1'
        PDescription ={'The order of the FIR low-pass filter'};
        return;
    case 'cardfrq.zeroxng.Fl'
        PDescription ={'The cut-off freq (Hz) of the low-pass filter'};
        return;
    case 'cardfrq.zeroxng.Nfir1'
        PDescription ={'The order of the FIR low-pass filter'};
        return;
    case 'cardfrq.HR_Fl'
        PDescription ={'The lower limit of the heart rate band (in Hz)'};
        return;
    case 'cardfrq.HR_Fh'
        PDescription ={'The higher limit of the heart rate band (in Hz)'};
        return;
    case 'voleffi.Nv'
        PDescription ={'Volume Efficiency window length (filter2S).'};
        return;
    otherwise
        error(['Error in paramName, input not recognized: ' ParamName]);
        MDescription = {'NaN'};
        return;
end

end

