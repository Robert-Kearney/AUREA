function [ MDescription ] = metricDescription( MCodeName )
%metricDescription Returns the input metric description for the
%	specified input string MCodeName.
%	[ MDescription ] = metricDescription( MCodeName )
%		outputs the description for the metric symbol
%       in MCodeName.
%
%   INPUT
%   MCodeName is a string with the metric name
%       as defined in [1].
%
%   OUTPUT
%   MDescription is a 1x1 cell array containing strings with the description of the input metric.
%
%   EXAMPLE
%   [ MCodeName, MDescription ] = metricName( '\phi' )
%
%   VERSION HISTORY
%   2014_02_12: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

switch MCodeName
    case 'resppwr_RCGxxx_win2sid'
        MDescription ={'Normalized power on breathing band RC'};
        return;
    case 'resppwr_ABDxxx_win2sid'
        MDescription = {'Normalized power on breathing band AB'};
        return;
    case 'br2mvpw_RCGxxx_filtbnk'
        MDescription = {'Comparison of powers in artifact and breathing bands RC'};
        return;
    case 'br2mvpw_ABDxxx_filtbnk'
        
        MDescription ={'Comparison of powers in artifact and breathing bands AB'} ;
        return;
    case 'taphase_RCGABD_bpbinsg'
        MDescription = {'Thoracoabdominal phase using band-pass filter';};
        return;
        
    case 'taphase_RCGABD_dtbinsg'
        MDescription = {'Thoracoabdominal phase reducing trends';};
        return;
    case 'rootmsq_RCGABD_win2sid'
        MDescription ={'Sum of RMS of RC and AB'} ;
        return;
    case 'respfrq_ABDxxx_filtbnk'
        MDescription = {'Respiratory frequency in AB using filter bank';};
        return;
    case 'respfrq_ABDxxx_zeroxng'
        MDescription = {'Respiratory frequency in AB using zero crossings'};
        return;
    case 'cardfrq_PPGxxx_filtbnk'
        MDescription ={ 'Cardiac frequency from PPG using filter bank';};
        return;
    case 'cardfrq_PPGxxx_zeroxng'
        MDescription ={  'Cardiac frequency from PPG using zero crossings';};
        return;
    case 'cardfrq_ECGxxx_filtbnk'
        MDescription = {'Cardiac frequency from ECG using filter bank'};
        return;
    case 'respfrq_RCGxxx_zeroxng'
        MDescription = {'Respiratory frequency in RC using zero crossings'};
        return;
    case 'raisfrq_RCGxxx_zeroxng'
        MDescription ={ 'Inspiratory frequency in RC using zero crossings'};
        return;
    case 'fallfrq_RCGxxx_zeroxng'
        MDescription = {'Expiratory frequency in RC using zero crossings'};
        return;
    case 'raisfrq_ABDxxx_zeroxng'
        MDescription ={'Inspiratory frequency in AB using zero crossings'} ;
        return;
    case 'fallfrq_ABDxxx_zeroxng'
        MDescription = {'Expiratory frequency in AB using zero crossings'};
        return;
    case 'raisfrq_PPGxxx_zeroxng'
        MDescription = {'Rising edge frequency in PPG using zero crossings'};
        return;
    case 'fallfrq_PPGxxx_zeroxng'
        MDescription = {'Falling edge frequency in PPG using zero crossings'};
        return;
    case 'sigbrea_RCGxxx_dtbinsg'
        MDescription ={'Breathing metric from RC'} ;
        return;
    case 'sigbrea_ABDxxx_dtbinsg'
        MDescription ={'Breathing metric from AB'} ;
        return;
    case 'sumbrea_RCGABD_dtbinsg'
        MDescription = {'Synchronous breathing metric'};
        return;
    case 'difbrea_RCGABD_dtbinsg'
        MDescription = {'Asynchronous breathing metric'};
        return;
    case 'nppnorm_RCGxxx_win2sid'
        MDescription ={'Normalized non-periodic power in RC'} ;
        return;
    case 'nppnorm_ABDxxx_win2sid'
        MDescription ={'Normalized non-periodic power in AB'};
        return;
    case 'nppnorm_PPGxxx_win2sid'
        MDescription ={'Normalized non-periodic power in PPG'};
        return;
    case 'varnorm_RCGxxx_win2sid'
        MDescription ={'Normalized variance of RCG'};
        return;
    case 'varnorm_ABDxxx_win2sid'
        MDescription ={'Normalized variance of ABD'};
        return;
    case 'xcorp00_RCGABD_win2sid'
        MDescription = {'Cross-correlation-coefficient between RC and AB. Where 00 and 0 correspond to the lag number.'};
        return;
    case 'xcorp00_RCGPPG_win2sid'
        MDescription = {'Cross-correlation-coefficient between RC and PPG'};
        return;
    case 'xcorp00_ABDPPG_win2sid'
        MDescription ={'Cross-correlation-coefficient between AB and PPG'};
        return;
    case 'xcorp00_RAZCPZ_win2sid'
        MDescription ={'Cross-correlation-coefficient between respiratory frequency and cardiac frequency from zero-crossings estimates';};
        return;
    case 'xcorp00_RAFCPF_win2sid'
        MDescription ={  'Cross-correlation-coefficient between respiratory frequency and cardiac frequency (PPG) from filter bank estimates';};
        return;
    case 'xcorp00_RAFCEF_win2sid'
        MDescription= { 'Cross-correlation-coefficient between respiratory frequency and cardiac frequency (ECG) from filter bank estimates';};
        return;
    case 'xcorp00_RAZSAT_win2sid'
        MDescription = {'Cross-correlation-coefficient between SAT and respiratory rate from zero-crossings estimates';};
        return;
    case 'xcorp00_RAFSAT_win2sid'
        MDescription = { 'Cross-correlation-coefficient between SAT and respiratory rate from filter bank estimates';};
        return;
    case 'sig2noi_RCGxxx_adpfilt'
        MDescription ={ 'SNR of RCG'};
        return;
    case 'sig2noi_ABDxxx_adpfilt'
        MDescription = {'SNR of ABD'};
        return;
    case 'sig2noi_PPGxxx_adpfilt'
        MDescription = {'SNR of PPG'};
        return;
    otherwise
        error(['Error in metricName, input not recognized: ' MCodeName]);
        MDescription = {'NaN'};
        return;
end


end


