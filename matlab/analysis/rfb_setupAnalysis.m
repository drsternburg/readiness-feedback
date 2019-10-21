
subjs_all = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl','VPfbm','VPfbn','VPfbo','VPfbp','VPfbq','VPfbr',...
             'VPfbs','VPfbt','VPfbu','VPfbv','VPfbw','VPfbx','VPfby','VPfbz'};
subjs_excl = {'VPfbf','VPfbn','VPfbq'}; % bad subjects: noisy acceleration data in both phases
subjs_sel = setxor(subjs_all,subjs_excl);

Ns = length(subjs_sel);

flag.premature = 0;
flag.duration_outlier = 0;
flag.cout_outlier = 0;
flag.eeg_artifact = 0;
flag.bad_online_onset = 1;

