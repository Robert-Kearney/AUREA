function [seqOut] = setMinPatLen (seqIn, minPatternLen)
% set minimum pattern length for a sequence
%   Detailed explanation goes here
%Input:
% seqIn - input categorical sequence
% minPAtternLen - minimumpatternlength in samples
%
% seqOut - sequence with minimumn patter length
% Change type of patterns with length <  MinPattLength based on preceeding
% and following sequences
% input must be a vcategorical vector of a cell  array of categorical
% vetors.
% If input is cell array returns a cell array of cateogrical variables;
if iscell(seqIn),
    nCase=length(seqIn);
    for iCase=1:nCase,
        seqOut{iCase,1}=setMinPatLenNew (seqIn{iCase}, minPatternLen);
    end
else
    seqOut=seqIn;
    winWidth=floor(minPatternLen/2);
    catList=categories(seqIn); 
    nSamp=length(seqIn);
    seqOut=categorical(nSamp);
    for i=1:nSamp,
        iStart=max(1,i-winWidth);
        iEnd=min(nSamp,i+winWidth);
        c=countcats(seqIn(iStart:iEnd));
        [m,im]=max(c);
        seqOut(i,1)=catList{im(1)};
    end
end
    
   