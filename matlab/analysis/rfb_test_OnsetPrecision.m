
subj_code = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl','VPfbm','VPfbn','VPfbo','VPfbp','VPfbq','VPfbr',...
             'VPfbs','VPfbt','VPfbu','VPfbv'};

flag.bad_online_onset = 0;
flag.duration_outlier = 0;
flag.cout_outlier = 0;
flag.premature = 0;
flag.eeg_artifact = 0;

%%
ii = 1;

%[trial,mrk,cnt,mnt] = rfb_getData(subj_code{ii},flag);
[trial,mrk,cnt,mnt] = rfb_getData('VPfbv',flag);

%%
SD = cell(2,1);
traces = cell(2,1);
for jj = 1:2
    
    traces{jj} = rfb_getMoveTraces(mrk{jj},trial{jj},cnt{jj},mo_classes{jj});
    
    cnt1 = proc_selectChannels(cnt{jj},'Acc*');
    mrk1 = rfb_selectTrials(mrk{jj},trial{jj}.valid);
    mrk1 = mrk_selectClasses(mrk1,mo_classes{jj});
    
    g = 9.80665;
    f = @(x) sqrt(sum(x.^2,2));
    
    Nt = length(trial{jj}.valid);
    ind = 1;
    SD{jj} = nan(Nt,1);
    for ii = 1:Nt
        if not(trial{jj}.valid(ii))
            continue
        end
        mrk2 = mrk_selectEvents(mrk1,ind);
        epo = proc_segmentation(cnt1,mrk2,[-700 -200]);
        SD{jj}(ii) = std(f(epo.x/g*100)); % m/s^2
        ind = ind+1;
    end
end

mn = nanmean(SD{1}(~isoutlier(SD{1})));
sd = nanstd(SD{1}(~isoutlier(SD{1})));
%mn = nanmean(SD{1});
%sd = nanstd(SD{1});
idx = SD{2}>mn+sd*3;

%%
ylim = [0 max([SD{1};SD{2}])];
figure
clrs = lines;

subplot 121
bar(SD{1},'FaceColor',clrs(1,:))
set(gca,'ylim',ylim)

subplot 122
hold on
bar(find(~idx),SD{2}(~idx),'FaceColor',clrs(5,:))
bar(find(idx),SD{2}(idx),'FaceColor',clrs(2,:))
set(gca,'ylim',ylim)

%%
figure

subplot 121
hold on
for kk = 1:length(traces{1})
    if isempty(traces{1}{kk})
        continue
    end
    plot(traces{1}{kk}.t,traces{1}{kk}.a,'color',clrs(4,:))
end

subplot 122
hold on
for jj = 1:2
    idx1 = find(idx==jj-1);
    for kk = 1:length(idx1)
        if isempty(traces{2}{idx1(kk)})
            continue
        end
        plot(traces{2}{idx1(kk)}.t,traces{2}{idx1(kk)}.a,'color',clrs(jj,:))
    end
end

















