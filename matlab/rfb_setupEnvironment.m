
global BTB opt

opt = struct;
opt.session_name = 'ReadinessFeedback';

%%
if ispc
    BTB.PrivateDir = 'C:\bbci';
end
addpath(fullfile(BTB.PrivateDir,'readiness-feedback','matlab','functions'))
addpath(fullfile(BTB.PrivateDir,'readiness-feedback','matlab','analysis'))
addpath(fullfile(BTB.PrivateDir,'readiness-feedback','matlab','acquisition'))

%%
BTB.Acq.Geometry = [1281 1 1280 998];
BTB.Acq.Dir = fullfile(BTB.PrivateDir,'readiness-feedback','acquisition');
BTB.Acq.IoAddr = hex2dec('0378');
BTB.PyffDir = 'C:\bbci\pyff\src';
BTB.Acq.Prefix = 'f';
BTB.Acq.StartLetter = 'a';
BTB.FigPos = [1 1];

%% parameters for raw data
opt.acq.bv_workspace = 'C:\Vision\Workfiles\ReadinessFeedback';
opt.acq.orig_fs = 1000;
Wps = [42 49]/opt.acq.orig_fs*2;
[n,Ws] = cheb2ord(Wps(1),Wps(2),3,40);
[opt.acq.filt.b,opt.acq.filt.a] = cheby2(n,50,Ws);
opt.acq.fs = 100;

%% markers
opt.mrk.def = { 2 'pedal press';...
               -30 'feedback'; ...
               -10 'trial start';...
               -11 'trial end';...
               -20 'block start';...
               -21 'block end'
               }';

%% parameters for finding movement onsets (accelerator)
opt.acc.ival = [-200 0];
opt.acc.offset = 500;

%% parameters or amplitude calculation
opt.amp.ival = [-200 0];

%% parameters for classification
opt.cfy_rp.clab_base = {'FC1','FC2','C1','Cz','C2','F1','Fz','F2','CP1','CPz','CP2'};
opt.cfy_rp.clab = opt.cfy_rp.clab_base;

opt.cfy_rp.ival_baseln = [-1000 -900];
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

opt.cfy_acc.clab = {'Acc*'};
opt.cfy_acc.ival_fv = opt.acc.ival;

% for the fake classifier of phase 1:
opt.cfy_rp.C.gamma = randn;
opt.cfy_rp.C.b = randn;
opt.cfy_rp.C.w = randn(size(opt.cfy_rp.ival_fv,1)*length(opt.cfy_rp.clab),1);

opt.cfy_acc.C.gamma = randn;
opt.cfy_acc.C.b = randn;
opt.cfy_acc.C.w = randn(3,1);

%% figure parameters
opt.fig.pred_edges = -2500:100:800;

%% feedback parameters
opt.feedback.name  = 'ReadinessFeedback';
opt.feedback.blocks = {'Practice_Phase1','Phase1','Practice_Phase2','Phase2'};
show_feedback = [0 0 1 1];
for ii = 1:length(opt.feedback.blocks)    
    opt.feedback.pyff_params(ii).show_feedback = int16(show_feedback(ii));
end

%%
clear  ii Wps Ws n show_feedback










