% DEMO_BBCIONLINE_APPLY_LSL_STREAMING
% this is just for testing / demonstrating the streaming of EEG data using
% lsl

% set up dummy classifier
C= struct('b', 0);
C.w= randn(30, 1);  % 2 log-bandpower feature per channel

% setup the bbci variable to define the online processing chain
bbci= struct;
bbci.log.clock = 1;
bbci.source.acquire_fcn= @bbci_acquire_lsl;
% define the dummy electrode setting

clab = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10'
};

bbci.signal.clab = clab;


bbci.source.acquire_param = {
    'fs', 5000, ...
    'clab', clab, ...
    'blocksize',10,...
    'chunk_size',5000,...
    'post_processing_option',4};


bbci.source.min_blocklength = 10;

bbci.feature.proc= {@proc_variance, @proc_logarithm};
bbci.feature.ival= [-500 0];
bbci.classifier.C= C;
bbci.feedback.receiver = '';

bbci.log.output= 'file';
bbci.log.file= fullfile(BTB.DataDir, 'tmp\log');    
bbci.source.record_signals = 1;
bbci.source.record_basename = fullfile(BTB.DataDir,'tmp\lsl_test');

bbci.quit_condition.running_time = 10;


bbci_apply(bbci);
