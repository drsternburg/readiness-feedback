
subj_code = 'VPfbl';
[trial,mrk,cnt,mnt] = rfb_getData(subj_code,1,1);

%%
Y = [trial{2}.feedback(trial{2}.valid)...
     trial{2}.t_mo2pp(trial{2}.valid)...
     trial{2}.t_ts2mo(trial{2}.valid)...
     trial{2}.trial_nr(trial{2}.valid)];
T = array2table(Y);
T.Properties.VariableNames = {'Feedback','Duration','WT','Trial'};

%%
formula = 'Feedback ~ Trial + Duration + WT';
%formula = 'Feedback ~ Trial + Duration + WT + Duration:WT';
lm = fitlm(T,formula);
disp(lm)

%%
formula = 'Trial ~ Duration*WT';
lm = fitlm(T,formula);
disp(lm)
