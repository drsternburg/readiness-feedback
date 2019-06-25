
global opt

%% setup participant
acq_makeDataFolder;

%% Test the triggers
bbci_trigger_parport(10,BTB.Acq.IoLib,BTB.Acq.IoAddr);


%% Training for Phase 1
rfb_startRecording('Practice_Phase1')
%% Phase 1
rfb_startRecording('Phase1')


%% Preprocess
rfb_convertBVData(BTB.Tp.Code,'Phase1');
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

%% Register onsets, inspect EEG signals, train online classifiers and save opt file
rfb_registerOnsets(BTB.Tp.Code,'Phase1');
rfb_quickInspection(BTB.Tp.Code);
save([fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'],'opt')

%% Training for Phase 2
rfb_startRecording('Practice_Phase2')
%% Phase 2
rfb_startRecording('Phase2')

