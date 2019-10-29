
flag.bad_online_onset = 1;
flag.duration_outlier = 1;
flag.cout_outlier = 1;
flag.premature = 1;
flag.eeg_artifact = 1;

%opt.cfy_rp.fv_window = [-1510 0];
%opt.cfy_rp.ival_baseln = [-1500 -1400];

epo = cell(Ns,1);
trial = cell(Ns,1);
for ii = 1:Ns
    
    [trial{ii},mrk,cnt,mnt] = rfb_getData(subjs_sel{ii},flag);
    epo{ii} = rfb_extractEpochs2(trial{ii},mrk,cnt);
    trial{ii} = rfb_extractAlpha(trial{ii},mrk,cnt,peak_alpha(ii));
    clear cnt mrk
    
end

save Hypo trial epo mnt