function [ metricAbbrev ] = metricAbbreviation( metricName )
%metricAbbreviation Returs the string symbol for the
%	specified input metric.
%	[metricAbbrev] = metricAbbreviation( metricName )
%		outputs the string symbol for the metric
%       in metricName.
%
%   INPUT
%   metricName is a string with the metric name
%       as defined in [1].
%
%   OUTPUT
%   metricAbbrev is a string with the symbol
%        for the metric in metricName [1].
%
%   EXAMPLE
%   [abbrev]=metricAbbreviation('sigbrea_ABDxxx_dtbinsg');
%
%   VERSION HISTORY
%   2014_03_13: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

switch metricName
    case 'resppwr_RCGxxx_win2sid'
        metricAbbrev='rp^{rc}';
        return;
    case 'resppwr_ABDxxx_win2sid'
        metricAbbrev='rp^{ab}';
        return;
    case 'br2mvpw_RCGxxx_filtbnk'
        metricAbbrev='bmp^{rc}';
        return;
    case 'br2mvpw_ABDxxx_filtbnk'
        metricAbbrev='bmp^{ab}';
        return;
    case 'taphase_RCGABD_bpbinsg'
        metricAbbrev='\phi';
        return;
    case 'rootmsq_RCGABD_win2sid'
        metricAbbrev='rms^{+}';
        return;
    case 'respfrq_ABDxxx_filtbnk'
        metricAbbrev='rf^{ab}';
        return;
    case 'cardfrq_PPGxxx_filtbnk'
        metricAbbrev='cf^{pp}';
        return;
    case 'cardfrq_ECGxxx_filtbnk'
        metricAbbrev='cf^{ec}';
        return;
    case 'respfrq_RCGxxx_zeroxng'
        metricAbbrev='rf^{rc}';
        return;
    case 'raisfrq_RCGxxx_zeroxng'
        metricAbbrev='if^{rc}';
        return;
    case 'fallfrq_RCGxxx_zeroxng'
        metricAbbrev='ef^{rc}';
        return;
    case 'respfrq_ABDxxx_zeroxng'
        metricAbbrev='rf^{ab}';
        return;
    case 'raisfrq_ABDxxx_zeroxng'
        metricAbbrev='if^{ab}';
        return;
    case 'fallfrq_ABDxxx_zeroxng'
        metricAbbrev='ef^{ab}';
        return;
    case 'cardfrq_PPGxxx_zeroxng'
        metricAbbrev='cf^{pp}';
        return;
    case 'raisfrq_PPGxxx_zeroxng'
        metricAbbrev='rif^{pp}';
        return;
    case 'fallfrq_PPGxxx_zeroxng'
        metricAbbrev='faf^{pp}';
        return;
    case 'sigbrea_RCGxxx_dtbinsg'
        metricAbbrev='b^{rc}';
        return;
    case 'sigbrea_ABDxxx_dtbinsg'
        metricAbbrev='b^{ab}';
        return;
    case 'sumbrea_RCGABD_dtbinsg'
        metricAbbrev='b^{+}';
        return;
    case 'difbrea_RCGABD_dtbinsg'
        metricAbbrev='b^{-}';
        return;
    case 'taphase_RCGABD_dtbinsg'
        metricAbbrev='\phi';
        return;
    case 'nppnorm_RCGxxx_win2sid'
        metricAbbrev='npp^{rc}';
        return;
    case 'nppnorm_ABDxxx_win2sid'
        metricAbbrev='npp^{ab}';
        return;
    case 'nppnorm_PPGxxx_win2sid'
        metricAbbrev='npp^{pp}';
        return;
    case 'varnorm_RCGxxx_win2sid'
        metricAbbrev='nv^{rc}';
        return;
    case 'varnorm_ABDxxx_win2sid'
        metricAbbrev='nv^{ab}';
        return;
    case 'xcorp00_RCGABD_win2sid'
        metricAbbrev='\rho_{0}^{rc-ab}';
        return;
    case 'xcorp00_RCGPPG_win2sid'
        metricAbbrev='\rho_{0}^{rc-pp}';
        return;
    case 'xcorp00_ABDPPG_win2sid'
        metricAbbrev='\rho_{0}^{ab-pp}';
        return;
    case 'xcorp00_RAZCPZ_win2sid'
        metricAbbrev='\rho_{0}^{rf-cf}';
        return;
    case 'xcorp00_RAFCPF_win2sid'
        metricAbbrev='\rho_{0}^{rf-cf}';
        return;
    case 'xcorp00_RAFCEF_win2sid'
        metricAbbrev='\rho_{0}^{rf-cf}';
        return;
    case 'xcorp00_RAZSAT_win2sid'
        metricAbbrev='\rho_{0}^{rf-sa}';
        return;
    case 'xcorp00_RAFSAT_win2sid'
        metricAbbrev='\rho_{0}^{rf-sa}';
        return;
    case 'sig2noi_RCGxxx_adpfilt'
        metricAbbrev='snr^{rc}';
        return;
    case 'sig2noi_ABDxxx_adpfilt'
        metricAbbrev='snr^{ab}';
        return;
    case 'sig2noi_PPGxxx_adpfilt'
        metricAbbrev = 'snr^{pp}';
        return;
    otherwise
        error(['Error in metricAbbreviation, input not recognized: ' metricName]);
        metricAbbrev='NaN';
        return;
end


end

