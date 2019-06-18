
function rfb_quickInspection(subj_code)
% Performs a quick inspection of recorded Phase1 data and returns the
% waiting times

global opt

%% prepare data
[mrk,cnt,mnt] = rfb_loadData(subj_code,'Phase1');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});

%% cross-validation
cnt_xv = proc_selectChannels(cnt,opt.cfy_rp.clab);
fv = proc_segmentation(cnt_xv,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);

opt.cfy_rp.C = train_RLDAshrink(fv.x,fv.y);

fv = proc_flaten(fv);
[loss,~,cout] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
acc = 100*(1-loss);
fprintf('\nClassification accuracy: %2.1f\n',acc)

%% Set cout for feedback
opt.feedback.pyff_params(3).phase1_cout = cout(logical(fv.y(2,:)));
opt.feedback.pyff_params(4).phase1_cout = cout(logical(fv.y(2,:)));

%% waiting time histogram
ci_emg = strcmp(mrk.className,'movement onset');
ci_ts = strcmp(mrk.className,'trial start');
i_emg = logical(mrk.y(logical(ci_emg),:));
i_ts = logical(mrk.y(logical(ci_ts),:));

t_ts2emg = mrk.time(i_emg) - mrk.time(i_ts);

figure
if verLessThan('matlab', '8.4')
    hist(t_ts2emg/1000)
else
    histogram(t_ts2emg/1000)
end
xlabel('Waiting time (s)')
ylabel('# counts')

%% visualization of RPs
epo = proc_segmentation(cnt,mrk,[-1200 0]);
epo = proc_baseline(epo,200,'beginning');
rsq = proc_rSquareSigned(epo);

figure
H = grid_plot(epo,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
