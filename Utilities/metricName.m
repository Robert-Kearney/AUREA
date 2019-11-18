function [ MCodeName, MDescription ] = metricName( metricAbbrev )
%metricAbbreviation Returns the input metric name and description for the
%	specified input string symbol.
%	[ MCodeName, MDescription ] = metricName( metricAbbrev )
%		outputs the code name and description for the metric symbol
%       in metricAbbrev.
%
%   INPUT
%   metricAbbrev is a string with the metric symbol
%       as defined in [1].
%
%   OUTPUT
%    MCodeName  is an Nx1 cell array containing strings with all the
%    applicable metric names which corresponds to the symbol in metricAbbrev [1].
%   MDescription is an Nx1 cell array containing strings with the description of the N metrics corresponding to metricAbbrev.
%
%   EXAMPLE
%   [ MCodeName, MDescription ] = metricName( '\phi' )
%
%   VERSION HISTORY
%   2014_02_12: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

switch metricAbbrev
    case 'rp^{rc}'
        MCodeName={'resppwr_RCGxxx_win2sid'};
        MDescription ={'Normalized power on breathing band RC'};
        return;
    case 'rp^{ab}'
        MCodeName={'resppwr_ABDxxx_win2sid'};
        MDescription = {'Normalized power on breathing band AB'};
        return;
    case 'bmp^{rc}'
        MCodeName={'br2mvpw_RCGxxx_filtbnk'};
        MDescription = {'Comparison of powers in artifact and breathing bands RC'};
        return;
    case 'bmp^{ab}'
        MCodeName={'br2mvpw_ABDxxx_filtbnk'};
        MDescription ={'Comparison of powers in artifact and breathing bands AB'} ;
        return;
    case '\phi'
        MCodeName={'taphase_RCGABD_bpbinsg'; 'taphase_RCGABD_dtbinsg'};
        MDescription = {'Thoracoabdominal phase using band-pass filter';
            'Thoracoabdominal phase reducing trends';};
        return;
    case 'rms^{+}'
        MCodeName={'rootmsq_RCGABD_win2sid'};
        MDescription ={'Sum of RMS of RC and AB'} ;
        return;
    case 'rf^{ab}'
        MCodeName={'respfrq_ABDxxx_filtbnk';'respfrq_ABDxxx_zeroxng'};
        MDescription = {'Respiratory frequency in AB using filter bank';
            'Respiratory frequency in AB using zero crossings'};
        return;
    case 'cf^{pp}'
        MCodeName={'cardfrq_PPGxxx_filtbnk';'cardfrq_PPGxxx_zeroxng'};
        MDescription ={ 'Cardiac frequency from PPG using filter bank';
            'Cardiac frequency from PPG using zero crossings';};
        return;
    case 'cf^{ec}'
        MCodeName={'cardfrq_ECGxxx_filtbnk'};
        MDescription = {'Cardiac frequency from ECG using filter bank'};
        return;
    case 'rf^{rc}'
        MCodeName= {'respfrq_RCGxxx_zeroxng'};
        MDescription = {'Respiratory frequency in RC using zero crossings'};
        return;
    case 'if^{rc}'
        MCodeName={'raisfrq_RCGxxx_zeroxng'};
        MDescription ={ 'Inspiratory frequency in RC using zero crossings'};
        return;
    case 'ef^{rc}'
        MCodeName={'fallfrq_RCGxxx_zeroxng'};
        MDescription = {'Expiratory frequency in RC using zero crossings'};
        return;
    case 'if^{ab}'
        MCodeName={'raisfrq_ABDxxx_zeroxng'};
        MDescription ={'Inspiratory frequency in AB using zero crossings'} ;
        return;
    case 'ef^{ab}'
        MCodeName={'fallfrq_ABDxxx_zeroxng'};
        MDescription = {'Expiratory frequency in AB using zero crossings'};
        return;
    case 'rif^{pp}'
        MCodeName={'raisfrq_PPGxxx_zeroxng'};
        MDescription = {'Rising edge frequency in PPG using zero crossings'};
        return;
    case 'faf^{pp}'
        MCodeName={'fallfrq_PPGxxx_zeroxng'};
        MDescription = {'Falling edge frequency in PPG using zero crossings'};
        return;
    case 'b^{rc}'
        MCodeName={'sigbrea_RCGxxx_dtbinsg'};
        MDescription ={'Breathing metric from RC'} ;
        return;
    case 'b^{ab}'
        MCodeName={'sigbrea_ABDxxx_dtbinsg'};
        MDescription ={'Breathing metric from AB'} ;
        return;
    case 'b^{+}'
        MCodeName={'sumbrea_RCGABD_dtbinsg'};
        MDescription = {'Synchronous breathing metric'};
        return;
    case 'b^{-}'
        MCodeName={'difbrea_RCGABD_dtbinsg'};
        MDescription = {'Asynchronous breathing metric'};
        return;
    case 'npp^{rc}'
        MCodeName={'nppnorm_RCGxxx_win2sid'};
        MDescription ={'Normalized non-periodic power in RC'} ;
        return;
    case 'npp^{ab}'
        MCodeName={'nppnorm_ABDxxx_win2sid'};
        MDescription ={'Normalized non-periodic power in AB'};
        return;
    case 'npp^{pp}'
        MCodeName={'nppnorm_PPGxxx_win2sid'};
        MDescription ={'Normalized non-periodic power in PPG'};
        return;
    case 'nv^{rc}'
        MCodeName={'varnorm_RCGxxx_win2sid'};
        MDescription ={'Normalized variance of RCG'};
        return;
    case 'nv^{ab}'
        MCodeName={'varnorm_ABDxxx_win2sid'};
        MDescription ={'Normalized variance of ABD'};
        return;
    case '\rho_{0}^{rc-ab}'
        MCodeName={'xcorp00_RCGABD_win2sid'};
        MDescription = {'Cross-correlation-coefficient between RC and AB. Where 00 and 0 correspond to the lag number.'};
        return;
    case '\rho_{0}^{rc-pp}'
        MCodeName={'xcorp00_RCGPPG_win2sid'};
        MDescription = {'Cross-correlation-coefficient between RC and PPG'};
        return;
    case '\rho_{0}^{ab-pp}'
        MCodeName={'xcorp00_ABDPPG_win2sid'};
        MDescription ={'Cross-correlation-coefficient between AB and PPG'};
        return;
    case '\rho_{0}^{rf-cf}'
        MCodeName={'xcorp00_RAZCPZ_win2sid';'xcorp00_RAFCPF_win2sid';
            'xcorp00_RAFCEF_win2sid'};
        MDescription ={'Cross-correlation-coefficient between respiratory frequency and cardiac frequency from zero-crossings estimates';
            'Cross-correlation-coefficient between respiratory frequency and cardiac frequency (PPG) from filter bank estimates';
            'Cross-correlation-coefficient between respiratory frequency and cardiac frequency (ECG) from filter bank estimates';};
        
        return;
    case '\rho_{0}^{rf-sa}'
        MCodeName={'xcorp00_RAZSAT_win2sid';'xcorp00_RAFSAT_win2sid'};
        MDescription = {'Cross-correlation-coefficient between SA and respiratory rate from zero-crossings estimates';
            'Cross-correlation-coefficient between SA and respiratory rate from filter bank estimates';};
        
        return;
    case 'snr^{rc}'
        MCodeName={'sig2noi_RCGxxx_adpfilt'};
        MDescription ={ 'SNR of RCG'};
        return;
    case 'snr^{ab}'
        MCodeName={'sig2noi_ABDxxx_adpfilt'};
        MDescription = {'SNR of ABD'};
        return;
    case 'snr^{pp}'
        MCodeName = {'sig2noi_PPGxxx_adpfilt'};
        MDescription = {'SNR of PPG'};
        return;
    otherwise
        error(['Error in metricName, input not recognized: ' metricAbbrev]);
        MCodeName={'NaN'};
        MDescription = {'NaN'};
        return;
end


end

