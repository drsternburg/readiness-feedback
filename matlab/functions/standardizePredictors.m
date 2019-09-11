
function Y = standardizePredictors(Y,pind)

Ns = length(unique(Y(:,end)));
Np = length(pind);
for si = 1:Ns
    sind = Y(:,end)==si;
    for pi = 1:Np
        Y(sind,pind(pi)) = zscore(Y(sind,pind(pi)));
    end
end