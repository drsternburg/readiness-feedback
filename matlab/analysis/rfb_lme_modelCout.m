
VariableNames = {'Feedback','WT','Duration','VelMean','VelMax','Trial','Block','Subj'};

%% Model selection
%T = array2table(Y);
T = array2table(standardizePredictors(Y,[2 3 4 5]));
T.Properties.VariableNames = VariableNames;

%% Model selection
T = T(:,[1 2 3 6 8]);
formula = mixedModelSelection(T,'Feedback');

%%
%formula = 'C ~ 1 + WT + WT:Dur + (1 | Subj)';
%formula = 'C ~ 1 + WT*Accel + (1 + WT | Subj)';
lme = fitlme(T,formula,'FitMethod','REML');
disp(lme)

%%
T2 = table();
Np = 100;
Nt = 12;
Block = 1:Nt;
Duration = linspace(prctile(T.Duration,1),prctile(T.Duration,99),Np);

P = zeros(Ns,Np,Nt);
for ii = 1:Ns
    T2.Subj = ones(Nt,1)*ii;
    T2.WT = ones(Nt,1)*median(T.WT(T.Subj==ii));
    for jj = 1:Np
        T2.Duration = ones(Nt,1)*Duration(jj);
        T2.Block = Block';
        P(ii,jj,:) = predict(lme,T2,'Conditional',1);
    end
end
P_mn = squeeze(mean(P));
P_se = squeeze(std(P))/sqrt(Ns);

%%
figure
surf(Block,Duration,P_mn)



































