
VariableNames = {'Feedback','WT','Duration','Trial','Subj'};

%%
T = array2table(Y(:,2:5));
T.Properties.VariableNames = VariableNames(2:5);
%formula = mixedModelSelection(T,'Duration');
formula = 'Trial ~ 1 + Duration*WT + (1 + WT + Duration | Subj)';
lme = fitlme(T,formula,'FitMethod','REML');
disp(lme)

%%
T2 = table();
T2.Trial = (1:300)';

P = zeros(Ns,length(T2.Trial),3);
for ii = 1:Ns
    T2.Subj = ones(length(T2.Trial),1)*ii;
    WT = prctile(T.WT(T.Subj==ii),[5 50 95]);
    for jj = 1:3
        T2.WT = ones(length(T2.Trial),1)*WT(jj);
        P(ii,:,jj) = predict(lme,T2,'Conditional',1);
    end
end

P_mn = squeeze(mean(P));
P_se = squeeze(std(P))/sqrt(Ns);


%%
Y2 = Y(:,3:5);
T = array2table(standardizePredictors(Y2,1));
T.Properties.VariableNames = {'Duration','Trial','Subj'};
%formula = mixedModelSelection(T,'Duration');
formula = 'Duration ~ 1 + Trial + (1 + Trial | Subj)';
lme = fitlme(T,formula,'FitMethod','REML');
disp(lme)



































