
function T = standardizePredictors2(T,P)

Ns = length(unique(T.Subj));
Np = length(P);
for si = 1:Ns
    for pi = 1:Np
        T.(P{pi})(T.Subj==si) = zscore(T.(P{pi})(T.Subj==si));
    end
end