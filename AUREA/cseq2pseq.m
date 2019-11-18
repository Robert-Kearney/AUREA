function pSeq = cseq2pseq(cseq)
% cSeq = pseq2categorical(pseq) Convert a cateorical sequence to a   pseq

%   Detailed explanation goes here
if iscell(cseq),
    for i=1:length(cseq),
        pSeq{i,1}=cseq2pseq(cseq{i});
    end
    return
else
    stateCodes= [ 0 1 2 4 3 5 6 11 99];
    pSeq=nan(size(cseq));
    for i=1:length(stateCodes),
        stateName=patternAbbreviation(stateCodes(i));
        [nRow,nCol]=size(cseq);
        for iCol=1:nCol
            [j]=find(cseq(:,iCol)==stateName);
            pSeq(j,iCol)=stateCodes(i)*ones(length(j),1);;
        end
    end
    return
end
