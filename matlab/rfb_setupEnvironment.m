
global BTB opt

opt = struct;
opt.session_name = 'ReadinessFeedback';

%%
if ispc
    BTB.PrivateDir = 'C:\bbci';
end
addpath(fullfile(BTB.PrivateDir,'readiness-feedback','matlab'))

%%
BTB.Acq.Geometry = [1281 1 1280 998];
BTB.Acq.Dir = fullfile(BTB.PrivateDir,'readiness-feedback','acquisition');
BTB.Acq.IoAddr = hex2dec('0378');
BTB.PyffDir = 'C:\bbci\pyff\src';
BTB.Acq.Prefix = 'f';
BTB.Acq.StartLetter = 'a';
BTB.FigPos = [1 1];

%% parameters for raw data
opt.acq.nr_eeg_chans = 62;  %!!!
opt.acq.nr_acc_chans = 3;  %!!!
opt.acq.bv_workspace = 'C:\Vision\Workfiles\ReadinessFeedback';
opt.acq.orig_fs = 1000;
Wps = [42 49]/opt.acq.orig_fs*2;
[n,Ws] = cheb2ord(Wps(1),Wps(2),3,40);
[opt.acq.filt.b,opt.acq.filt.a] = cheby2(n,50,Ws);
opt.acq.fs = 100;

%% markers
opt.mrk.min_ts2emg = 1500;
opt.mrk.def = { -2 'pedal press';...
               30 'feedback'; ...
               10 'trial start';...
               11 'trial end';...
               20 'block start';...
               21 'block end'
               }';

%% parameters for finding EMG onsets
opt.emg.wlen_bsln = 1000; % ms
opt.emg.wlen_det = 100; % ms
opt.emg.wlen_minWT = 1300; % ms
opt.emg.sd_fac = 5;
opt.emg.ival_valid = [-1000 -100];

%% parameters for finding movement onsets (accelerator)
opt.acc.ival = [-50 0];
opt.acc.offset = 500;

%% parameters for classification
opt.cfy_rp.ival_baseln = [-100 0];
opt.cfy_rp.ival_fv = [-1000 -900;
                   -900  -800;
                   -800  -700;
                   -700  -600;
                   -600  -500;
                   -500  -400;
                   -400  -300;
                   -300  -200;
                   -200  -100;
                   -100    0];
opt.cfy_rp.fv_window = [opt.cfy_rp.ival_fv(1)-10 0];
opt.cfy_rp.clab = {'not','E*','Acc*'};

opt.cfy_acc.clab = {'Acc*'};
opt.cfy_acc.ival_fv = opt.acc.ival;

% for the fake classifier of phase 1:
opt.cfy_rp.C.gamma = randn;
opt.cfy_rp.C.b = randn;
opt.cfy_rp.C.w = randn(size(opt.cfy_rp.ival_fv,1)*opt.acq.nr_eeg_chans,1);

opt.cfy_acc.C.gamma = randn;
opt.cfy_acc.C.b = randn;
opt.cfy_acc.C.w = randn(opt.acq.nr_acc_chans,1);

%% figure parameters
opt.fig.pred_edges = -2500:100:800;

%% feedback parameters
opt.feedback.name  = 'ReadinessFeedack';

opt.feedback.blocks = {'Practice_Phase1','Phase1','Practice_Phase2','Phase2'};

show_feedback = [0 0 1 1];

end_after_x_bps = [10
                   100
                   10
                   100
                   ];
                  
pause_every_x_bps = [10
                    25
                    10
                    25
                    ];

for ii = 1:length(opt.feedback.blocks)
    
    opt.feedback.pyff_params(ii).show_feedback = int16(show_feedback(ii));
    opt.feedback.pyff_params(ii).end_after_x_bps = int16(end_after_x_bps(ii));
    opt.feedback.pyff_params(ii).pause_every_x_bps = int16(pause_every_x_bps(ii));

    
end

%%
clear  ii Wps Ws n show_feedback end_after_x_bps pause_every_x_bps










