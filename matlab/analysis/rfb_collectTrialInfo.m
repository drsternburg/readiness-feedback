
flag.bad_online_onset = 1;
flag.duration_outlier = 0;
flag.cout_outlier = 1;
flag.premature = 1;
flag.eeg_artifact = 1;

trial_all = cell(Ns,1);
for ii = 1:Ns
    trial_all{ii} = rfb_getData(subjs_sel{ii},flag);
end

save trial_all trial_all

