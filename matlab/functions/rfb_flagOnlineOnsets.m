
function ind = rfb_flagOnlineOnsets(trial,cnt,mrk)

mo_classes = {'movement onset','mo online'};
f = @(x) sqrt(sum(x.^2,2));

SD = cell(2,1);
for jj = 1:2
    
    cnt1 = proc_selectChannels(cnt{jj},'Acc*');
    mrk1 = rfb_selectTrials(mrk{jj},trial{jj}.valid);
    mrk1 = mrk_selectClasses(mrk1,mo_classes{jj});
    
    Nt = length(trial{jj}.valid);
    ind = 1;
    SD{jj} = nan(Nt,1);
    for ii = 1:Nt
        if not(trial{jj}.valid(ii))
            continue
        end
        mrk2 = mrk_selectEvents(mrk1,ind);
        epo = proc_segmentation(cnt1,mrk2,[-700 -200]);
        SD{jj}(ii) = std(f(epo.x));
        ind = ind+1;
    end
end

mn = nanmean(SD{1}(~isoutlier(SD{1})));
sd = nanstd(SD{1}(~isoutlier(SD{1})));
ind = SD{2}>mn+sd*3;