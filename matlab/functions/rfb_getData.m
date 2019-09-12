
function [trial,mrk,cnt,mnt] = rfb_getData(subj_code,flag_outliers,flag_premature)

global opt

if not(exist('flag_outliers','var'))
    flag_outliers = 1;
end
if not(exist('flag_premature','var'))
    flag_premature = 0;
end

phases = {'Phase1','Phase2'};
mo_classes = {'movement onset','mo online'};

cnt = cell(2,1);
mrk = cell(2,1);
trial = cell(2,1);
for jj = 1:2
    fprintf('Loading and preprocessing dataset %s/%s...\n',subj_code,phases{jj})
    [mrk{jj},trial{jj}] = rfb_analyzeTrials(subj_code,phases{jj});
    [~,cnt{jj},mnt] = rfb_loadData(subj_code,phases{jj});
    if flag_outliers
        trial{jj} = rfb_flagOutliers(trial{jj});
        trial{jj} = rfb_flagArtifacts(trial{jj},mrk{jj},cnt{jj},mo_classes{jj});
    end
    if flag_premature
        ind_premature = trial{jj}.t_ts2mo<=-opt.cfy_rp.fv_window(1);
        trial{jj}.valid = trial{jj}.valid&~ind_premature;
        fprintf('%d trials with premature movements flagged\n',sum(ind_premature))
    end
end