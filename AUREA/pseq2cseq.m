function cSeq = pseq2cseq(pSeq)
% cSeq = pseq2categorical(pseq) Convert a pseq to categorical pseq

%   Detailed explanation goes here
if iscell(pSeq),
    for i=1:length(pSeq),
        cSeq{i}=pseq2cseq(pSeq{i});
    end
    return
else
    stateCodes= [ 0 1 2 4 3 5 6 11 99];
    stateNames={};
    for i=1:length(stateCodes),
        stateNames{i}=patternAbbreviation(stateCodes(i));
    end
    cSeq=categorical(pSeq,stateCodes, stateNames);
    return
end

