function [spec,freq]=getPeriodogram(x,numSegm,Fs)
    if ~exist('Fs','var') || isempty(Fs)
        Fs=1;
    end

    xlen=length(x);
    seglen=floor(xlen/numSegm);
    segments=zeros(seglen,numSegm);
    fftsegms=zeros(seglen,numSegm);
    psdsegms=zeros(seglen,numSegm);
    for index=1:numSegm
        segments(:,index)=x((index-1)*seglen+1:index*seglen);
        fftsegms(:,index)=fft(segments(:,index),seglen)./seglen;
        psdsegms(:,index)=abs(fftsegms(:,index)).^2;
    end
    aux=mean(psdsegms,2);
    sdx=std(psdsegms,[],2);
    spec.mean=aux(1:floor(seglen/2)+1);
    spec.std=sdx(1:floor(seglen/2)+1);
    freq=Fs/2*linspace(0,1,seglen/2+1)';
end