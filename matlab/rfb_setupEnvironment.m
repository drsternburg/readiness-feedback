
global BTB opt

opt = struct;
opt.session_name = 'ReadinessFeedback';

%%
if ispc
    BTB.PrivateDir = 'C:\bbci';
end
addpath(fullfile(BTB.PrivateDir,'readiness-feedback'))
addpath(fullfile(BTB.PrivateDir,'readiness-feedback','acquisition'))

%%
BTB.Acq.Geometry = [1281 1 1280 998];
BTB.Acq.Dir = fullfile(BTB.PrivateDir,'readiness-feedback','acquisition');
BTB.Acq.IoAddr = hex2dec('0378');
BTB.PyffDir = 'C:\bbci\pyff\src';
BTB.Acq.Prefix = 'r';
BTB.Acq.StartLetter = 'a';
BTB.FigPos = [1 1];

%% parameters for raw data
opt.eeg.nr_eeg_chans = 62;  %!!!
opt.eeg.bv_workspace = 'C:\Vision\Workfiles\ReadinessFeedback';
opt.eeg.orig_fs = 1000;
Wps = [42 49]/opt.eeg.orig_fs*2;
[n,Ws] = cheb2ord(Wps(1),Wps(2),3,40);
[opt.eeg.filt.b,opt.eeg.filt.a] = cheby2(n,50,Ws);
opt.eeg.fs = 100;

%% markers
opt.mrk.min_ts2emg = 1500;
opt.mrk.def = {  2 'button press';...
               -10 'trial start';...
               -11 'trial end';...
               -20 'block start';...
               -21 'block end'
               }';

%% parameters for finding EMG onsets
opt.emg.wlen_bsln = 1000; % ms
opt.emg.wlen_det = 100; % ms
opt.emg.wlen_minWT = 1300; % ms
opt.emg.sd_fac = 5;
opt.emg.ival_valid = [-1000 -100];

%% parameters for classification
opt.cfy.ival_baseln = [-100 0];
opt.cfy.ival_fv = [-1000 -900;
                   -900  -800;
                   -800  -700;
                   -700  -600;
                   -600  -500;
                   -500  -400;
                   -400  -300;
                   -300  -200;
                   -200  -100;
                   -100    0];
opt.cfy.fv_window = [opt.cfy.ival_fv(1)-10 0];
opt.cfy.clab = {'not','E*','Acc*'};

% for the fake classifier of phase 1:
opt.cfy.C_rp.gamma = randn;
opt.cfy.C_rp.b = randn;
opt.cfy.C_rp.w = randn(size(opt.cfy.ival_fv,1)*opt.eeg.nr_eeg_chans,1);

opt.cfy.C_emg.gamma = randn;
opt.cfy.C_emg.b = randn;
opt.cfy.C_emg.w = randn(size(opt.cfy.ival_fv,1)*opt.eeg.nr_eeg_chans,1);

%% parameters for finding optimal prediction threshold
opt.pred.tp_ival = [-600 -100];
opt.pred.fscore_beta = .5;
opt.pred.thresh_move = 10; % for the fake classifier of phase 1
opt.pred.thresh_idle = -10; % for the fake classifier of phase 1
opt.pred.wt_prctl = [10 75];

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
    
    opt.feedback.pyff_params(ii).listen_to_keyboard = int16(listen_to_keyboard(ii));
    opt.feedback.pyff_params(ii).show_feedback = int16(show_feedback(ii));
    opt.feedback.pyff_params(ii).end_pause_counter_type = int16(end_pause_counter_type(ii));
    opt.feedback.pyff_params(ii).end_after_x_bps = int16(end_after_x_events(ii));
    opt.feedback.pyff_params(ii).pause_every_x_bps = int16(pause_every_x_events(ii));
    
end

%%
clear  Wps Ws n listen_to_keyboard show_feedback end_after_x_events end_pause_counter_type pause_every_x_events










