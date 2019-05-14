
function rfb_registerEMGOnsets(subj_code)

global opt

[mrk,cnt] = rfb_loadData(subj_code,'Phase1');

%% prepare EMG data
cnt = proc_selectChannels(cnt,'EMG');
[b,a] = butter(6,20/cnt.fs*2,'high');
cnt = proc_filtfilt(cnt,b,a);

%% prepare markers
trial_mrk = rfb_getTrialMarkers(mrk);
i_ts = cellfun(@(v)v(1),trial_mrk);
i_bp = cellfun(@(v)v(2),trial_mrk);
i_te = cellfun(@(v)v(3),trial_mrk);
n_trial = length(i_ts);

%% get median standard deviation of EMG signal in first 1000ms of all trials
sd_bsln = zeros(opt.emg.wlen_bsln/10,length(i_ts));
for ii = 1:length(i_ts)
    epo = proc_segmentation(cnt,mrk_selectEvents(mrk,i_ts(ii)),[0 opt.emg.wlen_bsln]);
    sd_bsln(:,ii) = epo.x;
end
sd_bsln = sqrt(median(var(sd_bsln,1)));

%% trial by trial
t_emg = nan(1,n_trial);
ii = 1;
wlen_det = opt.emg.wlen_det/10;
while ii<=n_trial
    
    % extract EMG signal of trial
    t_ts = mrk.time(i_ts(ii));
    t_bp = mrk.time(i_bp(ii));
    t_te = mrk.time(i_te(ii));
    epo = proc_segmentation(cnt,mrk_selectEvents(mrk,i_ts(ii)),[0 t_te-t_ts]);
    
    % detect first 50ms window where SD > 3.5*SD_baseline
    i_start = opt.emg.wlen_minWT/10 + 1;
    i_emg = i_start;
    detected = false;
    while i_emg+wlen_det<=length(epo.x)
        sd = std(epo.x(i_emg:i_emg+wlen_det-1));
        if sd>sd_bsln*opt.emg.sd_fac
            if not(i_emg==i_start)
                detected = true;
            end
            break
        end
        i_emg = i_emg+1;
    end
    
    if detected
        t_emg_ = epo.t(i_emg) + t_ts + opt.emg.wlen_det/2; % add half the detection window
    else
        ii = ii+1;
        continue
    end
    
    if (t_emg_-t_bp)<opt.emg.ival_valid(1)&&(t_emg_-t_bp)>opt.emg.ival_valid(2)
        ii = ii+1;
        continue
    end
        
    t_emg(ii) = t_emg_;        
    
    ii = ii+1;
    
end

fprintf('%d EMG onsets assigned to %d trials.\n',sum(not(isnan(t_emg))),n_trial)

%% insert new markers
t_emg(isnan(t_emg)) = [];
mrk2.time = t_emg;
mrk2.y = ones(1,length(t_emg));
mrk2.className = {'EMG onset'};
mrk = mrk_mergeMarkers(mrk,mrk2);
mrk = mrk_sortChronologically(mrk);

%% cleanup lost button presses
trial_mrk = rfb_getTrialMarkers(mrk);
trial_ind = cellfun(@length,trial_mrk)==4;
mrk = mrk_selectEvents(mrk,[trial_mrk{trial_ind}]);
fprintf('%d trials removed with lost button presses.\n',sum(cellfun(@length,trial_mrk)==3))

%% plot
epo = proc_segmentation(cnt,mrk_selectClasses(mrk,'EMG onset'),[-1000 1000]);
figure
clrs = lines;
plot(epo.t,abs(squeeze(epo.x)),'color',clrs(1,:))

%% save new marker struct
global BTB
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,'Phase1',subj_code);
save(filename,'mrk')
















