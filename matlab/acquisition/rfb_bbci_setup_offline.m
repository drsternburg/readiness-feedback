
function bbci = rfb_bbci_setup_offline(cnt,mrk)

global opt

bbci = struct;

bbci.source.acquire_fcn = @bbci_acquire_offline;
bbci.source.acquire_param = {cnt,mrk,'blocksize',10,'realtime', 1};
bbci.log.clock = 1;
bbci.source.min_blocklength = 0;

bbci.signal(1).source = 1;
bbci.signal(1).clab = {'not','EMG'};

f_cutoff = 20;
[filt_emg_b,filt_emg_a] = butter(6,f_cutoff/opt.acq.fs*2,'high');
bbci.signal(2).source = 1;
bbci.signal(2).clab = {'EMG'};
bbci.signal(2).proc = {{@online_filt,filt_emg_b,filt_emg_a}};

bbci.feature(1).signal = 1;
bbci.feature(1).proc= {{@proc_baseline,opt.acq.baseln_len,opt.acq.baseln_pos}, ...
                       {@proc_jumpingMeans,opt.acq.rp_fv_ivals}};
bbci.feature(1).ival= [opt.acq.rp_fv_ivals(1) opt.acq.rp_fv_ivals(end)];

bbci.feature(2).signal = 2;
bbci.feature(2).proc= {@proc_variance,@proc_logarithm};
bbci.feature(2).ival= opt.acq.emg_fv_ival_on;

bbci.classifier(1).feature = 1;
bbci.classifier(1).C = opt.acq.C_rp;

bbci.classifier(2).feature = 2;
bbci.classifier(2).C = opt.acq.C_emg;

bbci.control(1).fcn = @sup_bbci_control_button;
%bbci.control(1).condition.marker = opt.mrk.def{1,strcmp(opt.mrk.def(2,:),'button press')};
bbci.control(1).condition.marker = 1;
bbci.control(1).param = {opt};

bbci.control(2).classifier = 1;
bbci.control(2).fcn = @sup_bbci_control_cout;
bbci.control(2).param = {opt};

bbci.control(3).classifier = 2;
bbci.control(3).fcn = @sup_bbci_control_emg;
bbci.control(3).param = {opt};

bbci.feedback(1).control= 1;
bbci.feedback(1).receiver= 'pyff';
bbci.feedback(2).control= 2;
bbci.feedback(2).receiver= 'pyff';
bbci.feedback(3).control= 3;
bbci.feedback(3).receiver= 'pyff';

bbci.quit_condition.marker = -255;

% bbci.log.output = 'screen';
% bbci.log.filebase = '~/bbci/log/log';
bbci.log.classifier = 1;

