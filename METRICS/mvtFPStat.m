function [Mnw,Mug,Mfp]  = mvtFPStat(X,Nm)
%MVTFPSTAT Movement test statistic for the Pleth
%   [Mnw,Mug,Mfp]  = mvtFPStat(X,Nm) returns the movement test statistic for
%   signal X.
%   X is an M-by-1 vector with either the ribcage or the abdominal
%      signal.
%   Nm is a scalar value with the length (in sample points) of the
%      sliding window.
%   M is an M-by-1 vector containing the movement test statistic
%      values.

[TotPWR_HR,TotPWR_MV,MaxPWR_MV,MaxPWR_HR,~] = FilterBankPleth(X,Nm);

%generate Test STAT for Movement Detect
Mnw=TotPWR_HR./TotPWR_MV;
Mug=TotPWR_HR./(TotPWR_MV+TotPWR_HR);
Mfp = (MaxPWR_HR - MaxPWR_MV)./(MaxPWR_HR + MaxPWR_MV);