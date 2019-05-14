
rfb_setupEnvironment;
global opt
warning off

%% setup participant
acq_makeDataFolder;

%% Start BrainVision Recorder and load workspace
system('C:\Vision\Recorder\Recorder.exe &'); pause(8);
bvr_sendcommand('loadworkspace',opt.eeg.bv_workspace);

%% Test the triggers
bbci_trigger_parport(10,BTB.Acq.IoLib,BTB.Acq.IoAddr);

%% Setup BBCI for phase 1
bbci = tl_bbci_setup;

%% Training for Phase 1
rfb_startRecording('Training1',bbci)

%% Phase 1
rfb_startRecording('Phase1',bbci)

%% Preprocess
basename = sprintf('%s_%s_',opt.session_name,'Phase1');
filename = fullfile(BTB.Tp.Dir(end-13:end),[basename BTB.Tp.Code]);
rfb_convertBVData(filename);
rfb_initialCleanup(BTB.Tp.Code,'Phase1');
rfb_registerEMGOnsets(BTB.Tp.Code);

%% Inspect data
cout = rfb_quickInspection;

%% update BBCI and set cout
bbci = rfb_bbci_setup;
opt.feedback.pyff_params(3).phase1_cout = cout;

%% Training for Phase 2
tl_acq_startRecording('Training2',bbci)

%% Phase 2
tl_acq_startRecording('Phase2',bbci)

%% Save options struct
optfile = [fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'];
save(optfile,'opt')




