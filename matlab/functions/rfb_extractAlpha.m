
function trial = rfb_extractAlpha(trial,mrk,cnt,freq_peak)

cls_nfo = {'movement onset','mo online'};

ival_alpha = [-1500 -1000];
[b,a] = butter(6,(freq_peak+[-2 2])/cnt{1}.fs*2);

for jj = 1:2
    
    Nt = length(trial{jj}.valid);
    trial{jj}.alpha = nan(Nt,1);
    mrk_ = rfb_selectTrials(mrk{jj},trial{jj}.valid);
    mrk_ = mrk_selectClasses(mrk_,{'trial start' cls_nfo{jj}});
    t_ts2mo = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
    invalid = t_ts2mo<-ival_alpha(1);
    mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj});
    
    cnt{jj} = proc_selectChannels(cnt{jj},util_chanind(cnt{jj},'Oz'));
    cnt{jj} = proc_filtfilt(cnt{jj},b,a);
    
    alpha = proc_segmentation(cnt{jj},mrk_,ival_alpha);
    alpha = proc_logarithm(proc_variance(alpha));
    alpha = squeeze(alpha.x);
    alpha(invalid) = NaN;
    
    trial{jj}.alpha(trial{jj}.valid) = alpha;
    
end