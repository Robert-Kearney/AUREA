function npp = nppNorm (x, nppParam, Fs)
% compute nppnormX_win2sid
npp=amplStat(x,nppParam.Nt_RIP,nppParam.Nm,nppParam.Nq,nppParam.Q,nppParam.No,nppParam.Normalize,Fs);
mpp(1:floor(nppParam.Nm/2))=nan;
npp(end-floor(nppParam.Nm/2):end)=nan;
return
