
function ind = isoutlier(x,nrep)

if nargin==1
    nrep = 1;
end

N = length(x);
ind = zeros(N,1);

for ii = 1:nrep
    mn = nanmedian(x);
    sd = nanstd(x);
    ind = ind | (x<mn-sd*3|x>mn+sd*3);
    x(ind) = NaN;
end
