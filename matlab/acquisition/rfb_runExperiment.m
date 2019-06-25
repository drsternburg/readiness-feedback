
global opt

%% setup participant
acq_makeDataFolder;

%% Test the triggers
bbci_trigger_parport(10,BTB.Acq.IoLib,BTB.Acq.IoAddr);

%% Setup BBCI for phase 1
bbci = rfb_bbci_setup;

%% Training for Phase 1
rfb_startRecording('Practice_Phase1',bbci)

%% Phase 1
rfb_startRecording('Phase1',bbci)

%% Preprocess
basename = sprintf('%s_%s_',opt.session_name,'Phase1');
filename = fullfile(BTB.Tp.Dir(end-13:end),[basename BTB.Tp.Code]);
rfb_convertBVData(filename);
rfb_initialCleanup(BTB.Tp.Code,'Phase1');
rfb_registerOnsets(BTB.Tp.Code,'Phase1');

%% Inspect data
cout = rfb_quickInspection(BTB.Tp.Code);

%% Train classifiers
[mrk,cnt] = rfb_loadData(BTB.Tp.Code,'Phase1');

cnt1 = proc_selectChannels(cnt,opt.cfy_rp.clab);
mrk1 = mrk_selectClasses(mrk,{'trial start','movement onset'});
fv = proc_segmentation(cnt1,mrk1,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);
opt.cfy_rp.C = train_RLDAshrink(fv.x,fv.y);

cnt1 = proc_selectChannels(cnt,opt.cfy_acc.clab);
mrk1 = mrk_selectClasses(mrk,{'trial start','pedal press'});
mrk1.time(logical(mrk1.y(1,:))) = mrk1.time(logical(mrk1.y(1,:))) + opt.acc.offset;
fv = proc_segmentation(cnt1,mrk1,opt.cfy_acc.ival_fv);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);
opt.cfy_acc.C = train_RLDAshrink(fv.x,fv.y);

%% update BBCI and set cout
bbci = rfb_bbci_setup;
opt.feedback.pyff_params(3).phase1_cout = cout;
opt.feedback.pyff_params(4).phase1_cout = cout;

%% Training for Phase 2
rfb_startRecording('Practice_Phase2',bbci)

%% Phase 2
rfb_startRecording('Phase2',bbci)

%% Save options struct
optfile = [fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'];
save(optfile,'opt')




