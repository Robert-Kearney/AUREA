function y = filternc(b,x,numsides)
%  performs one and two-sided filtering.
%
%  Syntax: y = filternc(b,x,numsides,incr)
%
% b       : filter impulse response
% x         : signal to filter
% numsides  : = 1 for a causal filter
%           : = 2 for an anticausal filter (default)
%
% for one sided filtering, this calls y=filter(b,1,x);

deprecate({'filter2S';'filter'});

[nr,nc]= size(x);
if nargin < 3
    numsides = 2;
end
numpts = length(x);
halflen = ceil(length(b)/2);
if numsides == 2
    x = [x ; zeros(halflen,nc)];
    y = filter(b,1,x);
    y = y(halflen:numpts + halflen - 1,:);
else 
    y = filter(b,1,x);
end