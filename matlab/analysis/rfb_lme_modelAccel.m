
VariableNames = {'C','WT','Dur','Accel','Trial','Subj'};

%%
Y2 = Y(:,[2 4 5 6]);
T = array2table(Y2);
T.Properties.VariableNames = {'WT','Accel','Trial','Subj'};
formula = mixedModelSelection(T,'Accel');
%formula = 'Accel ~ 1 + Trial*WT + (1 + Trial + WT | Subj)';
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





































