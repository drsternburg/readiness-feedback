
global opt

%% setup participant
acq_makeDataFolder;

%% Test the triggers
bbci_trigger_parport(10,BTB.Acq.IoLib,BTB.Acq.IoAddr);


%% Training for Phase 1
rfb_startRecording('Practice_Phase1',5,5)
%% Phase 1
rfb_startRecording('Phase1',100,25)


%% Preprocess
rfb_convertBVData(BTB.Tp.Code,'Phase1');
rfb_initialCleanup(BTB.Tp.Code,'Phase1');

%% Register onsets, inspect EEG signals, train online classifiers and save opt file
rfb_registerOnsets(BTB.Tp.Code,'Phase1');
rfb_quickInspection(BTB.Tp.Code);
save([fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'],'opt')

%% Training for Phase 2
rfb_startRecording('Practice_Phase2',5,5)
%% Phase 2.1
rfb_startRecording('Phase21',150,25)
%% Phase 2.2
rfb_startRecording('Phase22',150,25)
