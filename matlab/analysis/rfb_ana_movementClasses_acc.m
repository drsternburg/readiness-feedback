
subj_code = 'VPfae';
[~,cnt] = rfb_loadData(subj_code,'Phase2');
[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase2');

%% select trial with valid movement onset
block_nr = trial.block_nr(trial.valid_mo);
cout = trial.cout(trial.valid_mo);
fb = trial.feedback(trial.valid_mo);
mrk = rfb_selectTrials(mrk,trial.valid_mo);

%% segment accelerometer data
mrk = mrk_selectClasses(mrk,{'movement onset'});
acc = proc_selectChannels(cnt,'Acc*');
acc = proc_segmentation(acc,mrk,[-100 800]);
acc = proc_baseline(acc,[-100 0]);
%plot_channel(acc,'Acc*');

%% unsupervised classification of accelerometer traces
X = reshape(acc.x,size(acc.x,1)*3,size(acc.x,3));
%X = squeeze(acc.x(:,3,:));
I = kmedoids(X',2,'distance','correlation');

%% median split of velocity
t_mo2pp = trial.t_mo2pp_on(trial.valid_mo);
I = (t_mo2pp<=median(t_mo2pp))+1;

%% median split of waiting time
t_ts2mo = trial.t_ts2mo_off(trial.valid_mo);
I = (t_ts2mo<=median(t_ts2mo))+1;

%% median split of waiting time
t_ts2mo = trial.t_ts2mo_off(trial.valid_mo);
I = (t_ts2mo<=median(t_ts2mo))+1;

%% trial/block number
%I = block_nr;
I = (block_nr<3)+2;

%% anova
anova1(fb,I)