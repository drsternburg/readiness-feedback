
Y = [];
for ii = 1:Ns
    for jj = 1:2
        Nt = sum(trial{ii}{jj}.valid);
        y = [trial{ii}{jj}.cout(trial{ii}{jj}.valid) ...
             find(trial{ii}{jj}.valid) ...
             ones(Nt,1)*(jj-1) ...
             ones(Nt,1)*ii];
        Y = cat(1,Y,y);
    end
end
VariableNames = {'C','Trial','Phase','Subj'};

T = array2table(Y);
T.Properties.VariableNames = VariableNames;
T = standardizePredictors2(T,{'C'});


%% Predict C from Phase

formula = 'C ~ 1 + Phase + (1 + Phase | Subj)';

lme = fitlme(T,formula,'FitMethod','REML');
disp(lme)

P = predict(lme);

Pm = zeros(Ns,2);
for ii = 1:Ns
    for jj = 1:2
        Pm(ii,jj) = mean(P(T.Subj==ii&T.Phase==jj-1));
    end
end

%%
[muhat,sigmahat,muci,sigmaci] = normfit(Pm);

figure
clrs = lines;
hold on
for ii = 1:Ns
    plot([1 2],Pm(ii,:),'LineWidth',.5,'color',clrs(1,:))
end

% plot([1 2],muhat,'s','LineWidth',2,'color',clrs(1,:))
% for jj = 1:2
%     errorbar(jj,muhat(jj),muhat(jj)-muci(1,jj),muhat(jj)-muci(2,jj))
% end

boxplot(Pm)

set(gca,'xlim',[.5 2.5])

%% Predict C from Trials, Phase 1

formula = 'C ~ 1 + Trial + WT + (1 + Trial + WT | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
P = predict(lme);
figure
plot(T.Trial(T.Phase==0),P(T.Phase==0),'*')

%% Predict C from Trials, Phase 2

formula = 'C ~ 1 + Trial + (1 + Trial | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==0);
disp(lme)
P = predict(lme);
figure
plot(T.Trial(T.Phase==1),P(T.Phase==1),'*')

%% Single subjects, Trial effect Phase2

formula = 'C ~ 1 + Trial';

Est = cell(Ns,2);
for ii = 1:Ns
    T2 = T(T.Subj==ii&T.Phase==1,:);
    lm = fitlme(T2,formula);
    pval = lm.Coefficients.pValue(2);
    est = lm.Coefficients.Estimate(2);
    Est{ii,2} = [num2str(est) pval2astr(pval)];
    Est{ii,1} = subjs_sel{ii};
end
R = array2table(Est);
R.Properties.VariableNames = ['Subj' lm.CoefficientNames(2:end)];
disp(R)
























