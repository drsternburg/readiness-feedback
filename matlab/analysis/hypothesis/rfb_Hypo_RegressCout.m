
Y = [];
for ii = 1:Ns
    for jj = 1:2
        Nt = sum(trial{ii}{jj}.valid);
        y = [trial{ii}{jj}.cout(trial{ii}{jj}.valid) ...
             trial{ii}{jj}.t_ts2mo(trial{ii}{jj}.valid)/1000 ...
             trial{ii}{jj}.t_mo2pp(trial{ii}{jj}.valid) ...
             trial{ii}{jj}.alpha(trial{ii}{jj}.valid) ...
             find(trial{ii}{jj}.valid) ...
             ones(Nt,1)*(jj-1) ...
             ones(Nt,1)*ii];
        Y = cat(1,Y,y);
    end
end
VariableNames = {'C','WT','Dur','Alpha','Trial','Phase','Subj'};

T = array2table(Y);
T.Properties.VariableNames = VariableNames;
T = standardizePredictors(T,{'C'});


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

formula = 'C ~ 1 + Trial + (1 + Trial | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C from Trials, Phase 2

formula = 'C ~ 1 + Trial + (1 + Trial | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==0);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C from WT, Phase 1

formula = 'C ~ 1 + WT + (1 + WT | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C from WT, Phase 2

formula = 'C ~ 1 + WT + (1 + WT | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==0);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C from Alpha, Phase 1

formula = 'C ~ 1 + Alpha + (1 + Alpha | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
rfb_plotModelPredictions(lme,T)

%% Predict C from Alpha, Phase 2

formula = 'C ~ 1 + Alpha + (1 + Alpha | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==0);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C from Dur, Phase 1

formula = 'C ~ 1 + Dur + (1 + Dur | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
rfb_plotModelPredictions(lme,T)

%% Predict C from Dur, Phase 2

formula = 'C ~ 1 + Dur + (1 + Dur | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==0);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict C, Phase 2

formula = 'C ~ 1 + Trial*WT + (1 + Trial + WT | Subj)';

lme = fitlme(T,formula,'FitMethod','REML','Exclude',T.Phase==1);
disp(lme)
rfb_plotModelPredictions(lme,T)


%% Predict Phase
T = array2table(Y);
T.Properties.VariableNames = VariableNames;
%T = standardizePredictors(T,{'Dur','Alpha'});

formula = 'Phase ~ 1 + WT*Alpha*Dur + (1 + WT + Alpha + Dur | Subj)';

M = fitglme(T,formula,'Distribution','Binomial','Link','probit');
disp(M)













