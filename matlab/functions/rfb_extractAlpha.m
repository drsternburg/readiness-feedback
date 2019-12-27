%% for something other thing
function trial = rfb_extractAlpha(trial,mrk,cnt)
    

    

    ival_alpha = [-900 -100];


    for jj = 1:2


        Nt = length(trial{jj}.valid);
        trial{jj}.alpha = nan(Nt,1);
        mrk_ = rfb_selectTrials(mrk{jj});
        mrk_ = mrk_selectClasses(mrk_, 'trial start');
    %     t_ts2mo = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
    %     invalid = t_ts2mo<-ival_alpha(1);
    %     mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj});

        cnt{jj} = proc_selectChannels(cnt{jj},util_chanind(cnt{jj},'Oz'));

        % Get the alpha peak
        alpha_peak = proc_segmentation(cnt{jj},mrk_,ival_alpha);
        alpha_peak = proc_average(alpha_peak);
        alpha_peak = squeeze(alpha_peak.x(:,1));
        [pxx ,f ] = pwelch(alpha_peak, hamming(length(alpha_peak)), 0, 100, 100);
        [~, alpha_peak] = max(pxx(8:12));
        alpha_peak = alpha_peak+7;
        
        [b,a] = butter(6,(alpha_peak + [-2 2])/cnt{1}.fs*2);
        cnt{jj} = proc_filtfilt(cnt{jj},b,a);
        alpha = proc_segmentation(cnt{jj},mrk_,ival_alpha);
        alpha = proc_logarithm(proc_variance(alpha));
        alpha = squeeze(alpha.x);
        alpha(~trial{jj}.valid) = NaN;

        trial{jj}.alpha = alpha;

    end
end


%% find the highest alpha peak 
% max_alphas = zeros(Ns, 2);
% for ii=1:Ns
%     
%     for jj=1:2
% 
%         epo_target = proc_selectClasses(epo{ii}, {'Idle Phase 1', 'Idle Phase 2'});
%         epo_target = proc_selectChannels(epo_target, 'Oz');
%         epo_target = proc_selectIval(epo_target, [-800 -300]);
%         epo_target = proc_average(epo_target);
%         y = squeeze(epo_target.x(:,1,jj));
%         [pxx ,f ] = pwelch(y, hamming(length(y)), 0, 100, 100);
% %         plot(f,10*log10(pxx));
%         [~, max_alphas(ii, jj)] = max(pxx(8:12));
%     end
% end



%%
% 
% function trial = rfb_extractAlpha(trial,mrk,cnt,freq_peak)
% 
% cls_nfo = {'movement onset','mo online'};
% 
% ival_alpha = [-1500 -1000];
% 
% [b,a] = butter(6,(freq_peak+[-2 2])/cnt{1}.fs*2);
% 
% for jj = 1:2
%     
%     
%     
%     
%     Nt = length(trial{jj}.valid);
%     trial{jj}.alpha = nan(Nt,1);
%     mrk_ = rfb_selectTrials(mrk{jj},trial{jj}.valid);
%     mrk_ = mrk_selectClasses(mrk_,{'trial start' cls_nfo{jj}});
%     t_ts2mo = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
%     invalid = t_ts2mo<-ival_alpha(1);
%     mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj});
%     
%     cnt{jj} = proc_selectChannels(cnt{jj},util_chanind(cnt{jj},'Oz'));
%     cnt{jj} = proc_filtfilt(cnt{jj},b,a);
%     
%     alpha = proc_segmentation(cnt{jj},mrk_,ival_alpha);
%     alpha = proc_logarithm(proc_variance(alpha));
%     alpha = squeeze(alpha.x);
%     alpha(invalid) = NaN;
%     
%     trial{jj}.alpha(trial{jj}.valid) = alpha;
%     
% end