function [ MUnit ] = metricUnit( MCodeName )
%metricUnit Returns the metric unit.
%	[ MUnit ] = metricUnit( MCodeName )
%		outputs the unit of the metric MCodeName.
%
%   INPUT
%   MCodeName is a string with the metric code name
%       as defined in [1].
%
%   OUTPUT
%    MUnit is a string output containing the unit of MCodeName
%
%   EXAMPLE
%   [ MUnit] = metricUnit( 'resppwr_RCGxxx_win2sid' )
%
%   VERSION HISTORY
%   2014_04_30: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.

switch MCodeName
    case 'resppwr_RCGxxx_win2sid'
        MUnit='UL';
        return;
    case 'resppwr_ABDxxx_win2sid'
        MUnit='UL';
        return;
    case 'br2mvpw_RCGxxx_filtbnk'
        MUnit='UL';
        return;
    case 'br2mvpw_ABDxxx_filtbnk'
        MUnit='UL';
        return;
    case 'taphase_RCGABD_bpbinsg'
        MUnit='\circ/180';
        return;
    case 'rootmsq_RCGABD_win2sid'
        MUnit='AU';
        return;
    case 'respfrq_ABDxxx_filtbnk'
        MUnit='Hz';
        return;
    case 'cardfrq_PPGxxx_filtbnk'
        MUnit='Hz';
        return;
    case 'cardfrq_ECGxxx_filtbnk'
        MUnit='Hz';
        return;
    case 'respfrq_RCGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'raisfrq_RCGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'fallfrq_RCGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'respfrq_ABDxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'raisfrq_ABDxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'fallfrq_ABDxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'cardfrq_PPGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'raisfrq_PPGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'fallfrq_PPGxxx_zeroxng'
        MUnit='Hz';
        return;
    case 'sigbrea_RCGxxx_dtbinsg'
        MUnit='(AU)^2';
        return;
    case 'sigbrea_ABDxxx_dtbinsg'
        MUnit='(AU)^2';
        return;
    case 'sumbrea_RCGABD_dtbinsg'
        MUnit='(AU)^2';
        return;
    case 'difbrea_RCGABD_dtbinsg'
        MUnit='(AU)^2';
        return;
    case 'taphase_RCGABD_dtbinsg'
        MUnit='\circ/180';
        return;
    case 'nppnorm_RCGxxx_win2sid'
        MUnit='UL';
        return;
    case 'nppnorm_ABDxxx_win2sid'
        MUnit='UL';
        return;
    case 'nppnorm_PPGxxx_win2sid'
        MUnit='UL';
        return;
    case 'varnorm_RCGxxx_win2sid'
        MUnit='UL';
        return;
    case 'varnorm_ABDxxx_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RCGABD_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RCGPPG_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_ABDPPG_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RAZCPZ_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RAFCPF_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RAFCEF_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RAZSAT_win2sid'
        MUnit='UL';
        return;
    case 'xcorp00_RAFSAT_win2sid'
        MUnit='UL';
        return;
    case 'sig2noi_RCGxxx_adpfilt'
        MUnit='UL';
        return;
    case 'sig2noi_ABDxxx_adpfilt'
        MUnit='UL';
        return;
    case 'sig2noi_PPGxxx_adpfilt'
        MUnit = 'UL';
        return;
    otherwise
        error(['Error in metricUnit, input not recognized: ' MCodeName]);
        MUnit='NaN';
        return;
end


end

