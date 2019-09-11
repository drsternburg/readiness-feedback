
subj_code = {'VPfah','VPfai','VPfaj','VPfak','VPfal','VPfam','VPfan',...
             'VPfao','VPfap','VPfaq','VPfar','VPfas','VPfat','VPfau',...
             'VPfav','VPfaw'};
subj_code(strcmp(subj_code,'VPfam')) = []; % exclude VPfam due to very noisy data
subj_code(strcmp(subj_code,'VPfal')) = []; % exclude VPfal due to very short WTs
Ns = length(subj_code);

phase = 'Phase2';
mo_class = 'mo online';

Y = [];
for ii = 1:Ns
    
    % get data and remove outliers
    [mrk,trial] = rfb_analyzeTrials(subj_code{ii},phase);
    [~,cnt,mnt] = rfb_loadData(subj_code{ii},phase);
    trial = rfb_removeOutliers(trial);
    trial = rfb_removeArtifacts(trial,mrk,cnt,mo_class);
    [Acc_avg,Acc_max] = rfb_getAccelVars(mrk,trial,cnt,mo_class);
    
    % concat variables
    Nt = sum(trial.valid);
    y = [trial.cout(trial.valid) ...
         trial.t_ts2mo(trial.valid)/1000 ...
         trial.t_mo2pp(trial.valid) ...
         Acc_max(trial.valid) ...
         find(trial.valid) ...
         ones(Nt,1)*ii];
    Y = cat(1,Y,y);
end
