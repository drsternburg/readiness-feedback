
function mrk = rfb_registerOnsets(subj_code,phase_name)

global opt BTB

[~,cnt] = rfb_loadData(subj_code,phase_name);
cnt = proc_selectChannels(cnt,'Acc*');
dt = 1000/cnt.fs;

mrk_orig = rfb_analyzeTrials(subj_code,phase_name);

trial_mrk = rfb_getTrialMarkers(mrk_orig);
if strcmp(phase_name, 'Phase1')
    trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==3);
else
    trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);
end
mrk_orig = mrk_selectEvents(mrk_orig,[trial_mrk{:}]);

mrk_orig = mrk_selectClasses(mrk_orig,'not','movement onset');
mrk = mrk_selectClasses(mrk_orig,{'trial start','pedal press'});

%% train online detector
mrk_train = mrk;
mrk_train.time(logical(mrk.y(1,:))) = mrk_train.time(logical(mrk_train.y(1,:)))+opt.acc.offset;
fv = proc_segmentation(cnt,mrk_train,opt.acc.ival);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);
opt.cfy_acc.C = train_RLDAshrink(fv.x,fv.y);

%% find single-trial onsets with cross-validated detector
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
    t = T(2);
    while t >=T(1)
        fv = proc_segmentation(cnt,t,opt.acc.ival);
        fv = proc_variance(fv);
        fv = proc_logarithm(fv);
        fv = proc_flaten(fv);
        cout = apply_separatingHyperplane(C,fv.x(:));
        if cout<0
            t_onset(jj) = t;
            break
        end
        t = t-dt;
    end
    
end
t_onset(isnan(t_onset)) = [];

%% exclude outliers
mrk = mrk_selectClasses(mrk,'pedal press');
mrk2.time = t_onset;
mrk2.y = ones(1,length(t_onset));
mrk2.className = {'movement onset'};
mrk = mrk_mergeMarkers(mrk,mrk2);
mrk = mrk_sortChronologically(mrk);
t_mo2pp = mrk.time(logical(mrk.y(1,:))) - mrk.time(logical(mrk.y(2,:)));
ind_excl = (t_mo2pp>mean(t_mo2pp)+std(t_mo2pp)*3.5)|...
           (t_mo2pp<mean(t_mo2pp)-std(t_mo2pp)*3.5)|...
           (t_mo2pp<150); % physiologically implausible
t_onset(ind_excl) = [];
t_mo2pp(ind_excl) = [];
fprintf('%d Movement onsets assigned to %d trials.\n',length(t_onset),Nt)
fprintf('%d Movement onsets excluded as outliers.\n',sum(ind_excl))

%% insert new markers
mrk2.time = t_onset;
mrk2.y = ones(1,length(t_onset));
mrk2.className = {'movement onset'};
mrk = mrk_mergeMarkers(mrk_orig,mrk2);
mrk = mrk_sortChronologically(mrk);

%% plots
figure
clrs = lines;

subplot(4,1,1)
if verLessThan('matlab', '8.4')
    hist(t_mo2pp)
else
    histogram(t_mo2pp)
end

epo = proc_segmentation(cnt,mrk_selectClasses(mrk,'movement onset'),[-1000 1000]);
epo = proc_baseline(epo,500,'beginning');
for jj = 1:3
    subplot(4,1,jj+1)
    plot(epo.t,squeeze(squeeze(epo.x(:,jj,:))),'color',clrs(jj,:))
    title(epo.clab{jj})
end

%% save new marker struct
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,phase_name,subj_code);
save(filename,'mrk')
















