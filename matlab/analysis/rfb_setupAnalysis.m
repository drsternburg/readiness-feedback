
subjs_all = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl','VPfbm','VPfbn','VPfbo','VPfbp','VPfbq','VPfbr',...
             'VPfbs','VPfbt','VPfbu','VPfbv','VPfbw','VPfbx','VPfby','VPfbz'};
subjs_excl = {'VPfbf','VPfbn','VPfbq',...  % bad subjects: noisy acceleration data in both phases
              'VPfbz','VPfbo'}; % bad subjects: less than 50% trials remaining in phase 2 after exclusions
subjs_sel = setxor(subjs_all,subjs_excl);

Ns = length(subjs_sel);

peak_alpha = [12 10 10 11 10 11 11 11 9 10 11 11 10 11 10 10 8];

flag.premature = 1;
flag.duration_outlier = 0;
flag.cout_outlier = 1;
flag.eeg_artifact = 1;
flag.bad_online_onset = 1;

FIG_DIR = '/home/matthias/bbci/git/readiness-feedback/matlab/figures/';