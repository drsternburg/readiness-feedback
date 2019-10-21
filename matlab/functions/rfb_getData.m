
function [trial,mrk,cnt,mnt] = rfb_getData(subj_code,flag)

global opt

phases = {'Phase1','Phase2'};
mo_class = {'movement onset','mo online'};

cnt = cell(2,1);
mrk = cell(2,1);
trial = cell(2,1);
for jj = 1:2
    
    fprintf('Loading and processing dataset %s/%s...\n',subj_code,phases{jj})
    
    [mrk{jj},trial{jj}] = rfb_analyzeTrials(subj_code,phases{jj});
    [~,cnt{jj},mnt] = rfb_loadData(subj_code,phases{jj});
    
    trial{jj} = rfb_getAccelVars2(mrk{jj},trial{jj},cnt{jj},mo_class{jj});

end

if flag.bad_online_onset
    ind = rfb_flagOnlineOnsets(trial,cnt,mrk);
    trial{2}.valid = trial{2}.valid & ~ind;
    fprintf('%d trials with bad online movement onset flagged\n',sum(ind))
end

for jj = 1:2
    
    if flag.duration_outlier
        ind = isoutl(trial{jj}.t_mo2pp(trial{jj}.valid),'hi');
        trial{jj}.valid(trial{jj}.valid)= ~ind;
        fprintf('%d trials with outlier movement duration onset flagged\n',sum(ind))
    end
    
    if flag.cout_outlier
        ind = isoutl(trial{jj}.cout(trial{jj}.valid),'lohi');
        trial{jj}.valid(trial{jj}.valid)= ~ind;
        fprintf('%d trials with outlier classifier output flagged\n',sum(ind))
    end
        
    if flag.premature
        ind = trial{jj}.t_ts2mo<=-opt.cfy_rp.fv_window(1);
        trial{jj}.valid = trial{jj}.valid & ~ind;
        fprintf('%d trials with premature movements flagged\n',sum(ind))
    end
    
    if flag.eeg_artifact
        mrk_ = mrk_selectClasses(mrk{jj},mo_class{jj});
        epo = proc_segmentation(cnt{jj},mrk_,opt.cfy_rp.fv_window);
        [~,ind] = proc_rejectArtifactsMaxMin(epo,150,'Clab',trial{jj}.clab);
        trial{jj}.valid(ind) = false;
        fprintf('%d trials with EEG artifacts flagged\n',length(ind))
    end

end


