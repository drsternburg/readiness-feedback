
%[mrk,cnt] = tl_proc_loadData(subjs_all{17},'Phase1');
load TrafficLight_Phase1_VPtat.mat

%%
global opt

opt.acq.fs = 100;
opt.acq.baseln_len = 100;
opt.acq.baseln_pos = 'end';
fv_ivals = fliplr(-[0 50 100 200 300 450 650 900 1200]);
fv_ivals = [fv_ivals(1:end-1)'+10 fv_ivals(2:end)'];
opt.acq.rp_fv_ivals = fv_ivals;
opt.acq.emg_fv_ival_off = [-150 150];
opt.acq.emg_fv_ival_on = [-300 0];

%%
mrk_ = mrk_selectClasses(mrk,'EMG onset','start phase1');
fv = proc_selectChannels(cnt,'not','EMG');
fv = proc_segmentation(fv,mrk_,opt.acq.rp_fv_ivals([1 end]));
fv = proc_baseline(fv,opt.acq.baseln_len,opt.acq.baseln_pos);
fv = proc_jumpingMeans(fv,opt.acq.rp_fv_ivals);
fv = proc_flaten(fv);
opt.acq.C_rp = train_RLDAshrink(fv.x,fv.y);

%%
f_cutoff = 20;
[filt_emg_b,filt_emg_a] = butter(6,f_cutoff/opt.acq.fs*2,'high');
mrk_ = mrk_selectClasses(mrk,'start phase1','button press');
fv = proc_selectChannels(cnt,'EMG');
fv = proc_filt(fv,filt_emg_b,filt_emg_a);
fv = proc_segmentation(fv,mrk_,opt.acq.emg_fv_ival_off);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
opt.acq.C_emg = train_RLDAshrink(fv.x,fv.y);

%%
bbci = sup_bbci_setup_offline(cnt,mrk);
bbci_apply(bbci);
