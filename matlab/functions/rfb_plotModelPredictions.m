
function rfb_plotModelPredictions(M,T)

if length(M.CoefficientNames)>2
    error('Only works for one predictor')
end

RespName = M.ResponseName;
CoeffName = M.CoefficientNames{2};
Ns = length(unique(T.Subj));
include = ~isnan(response(M));

Pmarg = predict(M);
Pcond = predict(M,'conditional',0);

fig_init(15,15);
clrs = lines;
hold on

scatter(T.(CoeffName)(include),T.(RespName)(include),'.')

for ii = 1:Ns
    plot(T.(CoeffName)(T.Subj==ii&include),Pmarg(T.Subj==ii&include),'color',clrs(2,:))
end

plot(T.(CoeffName)(include),Pcond(include),'color',clrs(4,:),'linewidth',2)

xlabel(CoeffName)
ylabel(RespName)
box on
axis tight