
function rfb_registerOnsets_Acc(subj_code,phase_name)

global opt BTB

[mrk_orig,cnt] = rfb_loadData(subj_code,phase_name);

cnt = proc_selectChannels(cnt,'Acc*');
dt = 1000/cnt.fs;

trial_mrk = rfb_getTrialMarkers(mrk_orig);

%%% !!!
%trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==3);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);

mrk = mrk_selectEvents(mrk_orig,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','pedal press'});

Nt = sum(mrk.y(1,:));
i_trial = reshape(1:Nt*2,2,Nt);

t_onset = nan(Nt,1);
for jj = 1:Nt
    
    i_trial_ = i_trial(:,setdiff(1:Nt,jj));
    mrk_train = mrk_selectEvents(mrk,i_trial_(:));
    mrk_train.time(logical(mrk_train.y(1,:))) = mrk_train.time(logical(mrk_train.y(1,:)))+opt.acc.offset; 
    fv = proc_segmentation(cnt,mrk_train,opt.acc.ival);
    fv = proc_variance(fv);
    fv = proc_logarithm(fv);
    fv = proc_flaten(fv);
    C = train_RLDAshrink(fv.x,fv.y);
    
    mrk_trial = mrk_selectEvents(mrk,i_trial(:,jj));
    T = [mrk_trial.time(1)+opt.acc.offset mrk_trial.time(2)];
    t = T(1);
    while t <=T(2)
        fv = proc_segmentation(cnt,t,opt.acc.ival);
        fv = proc_variance(fv);
        fv = proc_logarithm(fv);
        fv = proc_flaten(fv);
        cout = apply_separatingHyperplane(C,fv.x(:));
        if cout>0
            t_onset(jj) = t;
            break
        end
        t = t+dt;
    end
    
end
fprintf('%d Movement onsets assigned to %d trials.\n',sum(not(isnan(t_onset))),Nt)

%% insert new markers
t_onset(isnan(t_onset)) = [];
mrk2.time = t_onset;
mrk2.y = ones(1,length(t_onset));
mrk2.className = {'movement onset'};
mrk = mrk_mergeMarkers(mrk_orig,mrk2);
mrk = mrk_sortChronologically(mrk);

%% plot
epo = proc_segmentation(cnt,mrk_selectClasses(mrk,'movement onset'),[-1000 1000]);
figure
clrs = lines;
for jj = 1:3
    subplot(3,1,jj)
    plot(epo.t,squeeze(squeeze(epo.x(:,jj,:))),'color',clrs(jj,:))
    title(epo.clab{jj})
end

%% save new marker struct
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,phase_name,subj_code);
save(filename,'mrk')















