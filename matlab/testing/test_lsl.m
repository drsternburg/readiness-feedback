% DEMO_BBCIONLINE_APPLY_LSL_STREAMING
% this is just for testing / demonstrating the streaming of EEG data using
% lsl

% set up dummy classifier
C= struct('b', 0);
C.w= randn(8*4, 1);  % 2 log-bandpower feature per channel

% setup the bbci variable to define the online processing chain
bbci= struct;
bbci.log.clock = 1;
bbci.source.acquire_fcn= @bbci_acquire_lsl;
% define the dummy electrode setting
clab_amp1 = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10', 'EOGv', 'EOGl'};
    
clab_amp2 = {'F1', 'F2', 'C1', 'C2', 'P1', 'P2',...
    'AF3', 'AF4', 'FC3', 'FC4', 'CP3', 'CP4',...
    'PO3', 'PO4', 'F5', 'F6', 'C5', 'C6', 'P5',...
    'P6', 'AF7', 'AF8', 'FT7', 'FT8', 'TP7', 'TP8',...
    'PO7', 'PO8', 'Fpz', 'AFz', 'CPz', 'POz'};
clab = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10', 'EOGv', 'EOGl',...
    'F1', 'F2', 'C1', 'C2', 'P1', 'P2',...
    'AF3', 'AF4', 'FC3', 'FC4', 'CP3', 'CP4',...
    'PO3', 'PO4', 'F5', 'F6', 'C5', 'C6', 'P5',...
    'P6', 'AF7', 'AF8', 'FT7', 'FT8', 'TP7', 'TP8',...
    'PO7', 'PO8', 'Fpz', 'AFz', 'CPz', 'POz'
};

% bbci.signal.clab = clab;

acquire_param = {'clab', clab_amp1, 'fs', 10, 'blocksize', 1};

% This is recording at about 100hz interestingly. 
% acquire_param = {'clab', clab_amp1, 'fs', 2500, 'blocksize', 10};

% This is recorfding at every 5ms
% acquire_param = {'clab', clab_amp1, 'fs', 1500, 'blocksize', 10};

% acquire_param{2} = {'clab', clab_amp1,...
%     'markerstreamname', 'BrainAmpSeries-1-Sampled-Markers',...
%     'eeg_amp_num', 1};
% acquire_param{3} = {'clab', clab_amp2, ...
%     'markerstreamname', 'BrainAmpSeries-2-Sampled-Markers', ...
%     'eeg_amp_num', 2};

bbci.source.acquire_param = acquire_param;
bbci.source.min_blocklength = 10;
bbci.feature.proc= {@proc_variance, @proc_logarithm};
bbci.feature.ival= [-500 0];
bbci.classifier.C= C;
% 
BTB.Tp.Dir = 'C:\tmp';
bbci.source.record_signals = 1;
bbci.source.record.fcn = 'internal';
bbci.source.record_basename = 'testing_lsl';

bbci.log.output = 0;
bbci.log.output= 'file';
bbci.log.folder= BTB.Tp.Dir;

bbci.control.fcn = @sup_bbci_control_cout;
bbci.feedback.receiver = '';

bbci.quit_condition.running_time = 60;
tic
bbci_apply(bbci);
toc