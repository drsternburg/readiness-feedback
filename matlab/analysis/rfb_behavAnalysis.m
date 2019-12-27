%% Get all the things

variable = 't_ts2mo';
phase = 1;

couts = [];
vars = [];
for ii=1:Ns
    couts = vertcat(couts,trial{ii}{phase}.cout(trial{ii}{phase}.valid));
    vars = vertcat(vars,trial{ii}{phase}.(variable)(trial{ii}{phase}.valid));
end

% [~, si] = sort(vars);
% plot(vars(si));
% hold on 
% plot(couts(si));

%%

variable = 'alpha';

Y = [];
for ii = 1:Ns
    for jj = 1:2
%         Nt_all = length(trial{ii}{jj}.cout);
%         blocks = [];
%         for kk=1:Nt_all
%             phase
%             blocks = vertcat(blocks, kk)
%         end
%         
        Nt = sum(trial{ii}{jj}.valid);
        v = trial{ii}{jj}.(variable)(trial{ii}{jj}.valid);
        
        y = [trial{ii}{jj}.cout(trial{ii}{jj}.valid) ...
             trial{ii}{jj}.t_ts2mo(trial{ii}{jj}.valid)/1000 ...
             trial{ii}{jj}.t_mo2pp(trial{ii}{jj}.valid) ...
             trial{ii}{jj}.alpha(trial{ii}{jj}.valid) ...
             find(trial{ii}{jj}.valid) ...
             ones(Nt,1)*(jj-1) ...
             ones(Nt,1)*ii...
             (v-nanmean(v))/nanstd(v)...
             ceil(find(trial{ii}{jj}.valid)/25)...
             sort(trial{ii}{jj}.t_ts2mo(trial{ii}{jj}.valid)/1000)];
        Y = cat(1,Y,y);
    end
end
VariableNames = {'C','WT','Dur','Alpha','Trial','Phase','Subj','Z', 'Block', 'Sort_wt'};

T = array2table(Y);
T.Properties.VariableNames = VariableNames;
T = standardizePredictors(T,{ 'C'});


%% regression stuff

mdl = fitlm(T,'Alpha ~ WT', 'Exclude', T.Phase==0);
plotAdded(mdl);
disp(mdl);
% disp(corr(vars, couts));

%% 

formula = 'Alpha ~ 1 + WT + (1 + WT | Subj) ';

lme = fitlme(T,formula,'FitMethod','REML', 'Exclude',T.Phase==0);
disp(lme)
rfb_plotModelPredictions(lme,T)

%% 


mdl = fitnlm(T,'Alpha ~ WT', 'Exclude', T.Phase==0);
plotAdded(mdl);
disp(mdl);