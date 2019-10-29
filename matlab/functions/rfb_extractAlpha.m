
function trial = rfb_extractAlpha(trial,mrk,cnt)

cls_nfo = {'movement onset','mo online'};

ival_alpha = [-1500 -1000];
[b,a] = butter(6,[8 12]/cnt{1}.fs*2);

for jj = 1:2
    
    Nt = length(trial{jj}.valid);
    trial{jj}.alpha = nan(Nt,1);
    mrk_ = rfb_selectTrials(mrk{jj},trial{jj}.valid);
    mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj});
    
    cnt{jj} = proc_selectChannels(cnt{jj},util_chanind(cnt{jj},'Oz'));
    cnt{jj} = proc_filtfilt(cnt{jj},b,a);
    
    epo = proc_segmentation(cnt{jj},mrk_,ival_alpha);
    epo = proc_logarithm(proc_variance(epo));
    
    trial{jj}.alpha(trial{jj}.valid) = squeeze(epo.x);
    
end