
VariableNames = {'C','WT','Dur','Accel','Trial','Subj'};

%% Model selection
Y2 = standardizePredictors(Y,1);
Y2 = Y2(:,[1 2 4 5 6]);
T = array2table(Y2);
T.Properties.VariableNames = {'C','WT','Accel','Trial','Subj'};
%formula = mixedModelSelection(T,'C');
formula = 'C ~ 1 + WT + WT:Accel + (1 | Subj)';
%formula = 'C ~ 1 + WT*Accel + (1 + WT | Subj)';
lme = fitlme(T,formula,'FitMethod','REML');
disp(lme)

%%
T2 = table();
Np = 100;
Accel = linspace(prctile(T.Accel,1),prctile(T.Accel,99),Np);
WT = linspace(prctile(T.WT,1),prctile(T.WT,99),Np);

P = zeros(Ns,Np,Np);
for ii = 1:Ns
    T2.Subj = ones(Np,1)*ii;
    for jj = 1:Np
        T2.Accel = ones(Np,1)*Accel(jj);
        T2.WT = WT';
        P(ii,jj,:) = predict(lme,T2,'Conditional',1);
    end
end
P_mn = squeeze(mean(P));
P_se = squeeze(std(P))/sqrt(Ns);




































