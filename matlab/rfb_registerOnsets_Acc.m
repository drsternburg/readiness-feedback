
function rfb_registerOnsets_Acc(cnt,mrk)

%global opt BTB

ival = [-50 0];
offset = 500;

cnt = proc_selectChannels(cnt,'Acc*');
dt = 1000/cnt.fs;

mrk = mrk_selectClasses(mrk,{'trial start','pedal press'});
Nt = sum(mrk.y(1,:));
i_trial = reshape(1:Nt*2,2,Nt);

t_onset = nan(Nt,1);
for jj = 1:Nt
    
    i_trial_ = i_trial(:,setdiff(1:Nt,jj));
    mrk_train = mrk_selectEvents(mrk,i_trial_(:));
    fv = proc_segmentation(cnt,mrk_train,ival);
    fv = proc_variance(fv);
    fv = proc_logarithm(fv);
    fv = proc_flaten(fv);
    C = train_RLDAshrink(fv.x,fv.y);
    
    mrk_trial = mrk_selectEvents(mrk,i_trial(:,jj));
    T = [mrk_trial.time(1)+offset mrk_trial.time(2)];
    t = T(1);
    while t <=T(2)
        fv = proc_segmentation(cnt,t,ival);
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
fprintf('%d EMG onsets assigned to %d trials.\n',sum(not(isnan(t_onset))),Nt)

%% insert new markers
t_onset(isnan(t_onset)) = [];
mrk2.time = t_onset;
mrk2.y = ones(1,length(t_onset));
mrk2.className = {'movement onset'};
mrk = mrk_mergeMarkers(mrk,mrk2);
mrk = mrk_sortChronologically(mrk);

%% plot
epo = proc_segmentation(cnt,mrk_selectClasses(mrk,'movement onset'),[-1000 1000]);
figure
clrs = lines;
plot(epo.t,abs(squeeze(epo.x)),'color',clrs(1,:))

%% save new marker struct
% ds_list = dir(BTB.MatDir);
% ds_idx = strncmp(subj_code,{ds_list.name},5);
% ds_name = ds_list(ds_idx).name;
% filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,'Phase1',subj_code);
% save(filename,'mrk')
















