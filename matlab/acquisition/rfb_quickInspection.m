
function rfb_quickInspection(subj_code)

global opt

%% prepare data
[mrk,cnt] = rfb_loadData(subj_code,'Phase1');
cnt = proc_commonAverageReference(cnt);

trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});

%% Exclude too short waiting times
mrk_mo = mrk_selectClasses(mrk, 'movement onset');
mrk_ts = mrk_selectClasses(mrk, 'trial start');
t_ts2mo = mrk_mo.time - mrk_ts.time;
ind_valid = t_ts2mo>=-opt.cfy_rp.fv_window(1);
mrk = mrk_mergeMarkers(mrk_selectEvents(mrk_ts, ind_valid),...
    mrk_selectEvents(mrk_mo, ind_valid));

%%
epo = proc_segmentation(cnt,mrk,opt.cfy_rp.fv_window);
epo = proc_baseline(epo,opt.cfy_rp.ival_baseln);

epo = proc_rejectArtifactsMaxMin(epo,150,'verbose',1,'Clab',opt.cfy_rp.clab_base);

rsq = proc_rSquareSigned(epo,'Stats',1);

epo_ = proc_selectChannels(epo,opt.cfy_rp.clab_base);
rsq_ = proc_rSquareSigned(epo_,'Stats',1);
amp = proc_meanAcrossTime(epo_,opt.amp.ival);

%% (i) sum of r-squared values must be larger than zero, and select all channels above median
sum_rsq = sum(rsq_.x);
chanind_1 = sum_rsq>0;
%% (ii) RP+ amplitudes must be smaller than zero
%[~,pval] = ttest(squeeze(amp.x(1,:,logical(amp.y(2,:))))',0,'tail','left');
[~,pval] = ttest(squeeze(amp.x(1,:,logical(amp.y(2,:))))',0,.05,'left');
chanind_2 = pval<.05;
%% (iii) RP+ amplitudes must be smaller than RP- amplitudes
[~,pval] = ttest2(squeeze(amp.x(1,:,logical(amp.y(2,:))))',...
                  squeeze(amp.x(1,:,logical(amp.y(1,:))))',...
                  .05,'left');
chanind_3 = pval<.05;

%% channel selection
opt.cfy_rp.clab = epo_.clab(chanind_1&chanind_2&chanind_3);
disp(opt.cfy_rp.clab)

%% define online filter
Nc = length(opt.acq.clab);
rc = util_scalpChannels(opt.acq.clab);
rrc = util_chanind(opt.acq.clab,opt.cfy_rp.clab);
opt.acq.A = eye(Nc,Nc);
opt.acq.A(rc,rrc) = opt.acq.A(rc,rrc) - 1/length(rc);
opt.acq.A = opt.acq.A(:,rrc);

%% re-load data and apply online filter
[~,cnt,mnt] = rfb_loadData(subj_code,'Phase1');
cnt = proc_linearDerivation(cnt,opt.acq.A);

%% extract features and train online classifier
fv = proc_segmentation(cnt,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);

opt.cfy_rp.C = train_RLDAshrink(fv.x,fv.y);

%% cross-validation
warning off
[loss,~,cout] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
warning on
fprintf('\nClassification accuracy: %2.1f%%\n',100*(1-loss))

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
figure
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[.9 .9]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
% for jj = 1:length(H.chan)
%     if any(strcmp(H.chan(jj).ax_title.String,opt.cfy_rp.clab))
%         set(H.chan(jj).ax_title,'FontWeight','bold')
%     end
% end
