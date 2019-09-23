
% subj_code = {'VPfah','VPfai','VPfaj','VPfak','VPfal','VPfam','VPfan',...
%              'VPfao','VPfap','VPfaq','VPfar','VPfas','VPfat','VPfau',...
%              'VPfav','VPfaw'};
% subj_code(strcmp(subj_code,'VPfam')) = []; % exclude VPfam due to very noisy data
% subj_code(strcmp(subj_code,'VPfal')) = []; % exclude VPfal due to very short WTs

subj_code = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl'};

Ns = length(subj_code);

phase = 'Phase2';
mo_class = 'mo online';
flag_outliers = 1;
flag_premature = 1;

Y = [];
for ii = 1:Ns
    
    % get data and remove outliers
    trial = rfb_getData(subj_code{ii},flag_outliers,flag_premature);
    trial = trial{2};
    
    % concat variables
    Nt = sum(trial.valid);
    y = [trial.feedback(trial.valid) ...
         trial.t_ts2mo(trial.valid)/1000 ...
         trial.t_mo2pp(trial.valid) ...
         find(trial.valid) ...
         ones(Nt,1)*ii];
    Y = cat(1,Y,y);
end

VariableNames = {'Feedback','WT','Duration','Trial','Subj'};
