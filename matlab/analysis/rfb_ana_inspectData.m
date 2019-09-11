
subj_code = 'VPfau';

%%
phases = {'Phase1','Phase2'};
mo_classes = {'movement onset','mo online'};
var_names = {'Classifier output (a.u.)',...
             'Waiting time (sec)',...
             'Movement duration (ms)'};
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};

%% get data and remove outliers
cnt = cell(2,1);
mrk = cell(2,1);
trial = cell(2,1);
for jj = 1:2
    [mrk{jj},trial{jj}] = rfb_analyzeTrials(subj_code,phases{jj});
    [~,cnt{jj},mnt] = rfb_loadData(subj_code,phases{jj});
    trial{jj} = rfb_removeOutliers(trial{jj});
    trial{jj} = rfb_removeArtifacts(trial{jj},mrk{jj},cnt{jj},mo_classes{jj});
end

%% compare phases
X = cell(3,2);
for jj = 1:2
    X{1,jj} = trial{jj}.cout(trial{jj}.valid);
    X{2,jj} = trial{jj}.t_ts2mo(trial{jj}.valid)/1000;
    X{3,jj} = trial{jj}.t_mo2pp(trial{jj}.valid);
end
pval = zeros(3,1);
for jj = 1:3
    %[~,pval(jj)] = ttest2(X{jj,1},X{jj,2});
    pval(jj) = ranksum(X{jj,1},X{jj,2});
end

fig_init(30,30);
clrs = lines;

for jj = 1:3
    
    x1 = X{jj,1};
    m1 = mean(x1);
    x2 = X{jj,2};
    m2 = mean(x2);
    
    subplot(3,4,(1:3)+(jj-1)*4)
    hold on
    bar(1:length(x1),x1,'FaceColor',clrs(1,:))
    bar(length(x1)+1:length(x1)+length(x2),x2,'FaceColor',clrs(2,:))
    ylim1 = get(gca,'ylim');
    ylabel(var_names{jj})
    if jj==3
        xlabel('Trial')
    end
    
    subplot(3,4,4+(jj-1)*4)
    histogram(x1,'Normalization','pdf')
    hold on
    histogram(x2,'Normalization','pdf')
    ylim2 = get(gca,'ylim');
    xlim2 = get(gca,'xlim');
    plot([m1 m1],ylim2,'color',clrs(1,:),'linewidth',2)
    plot([m2 m2],ylim2,'color',clrs(2,:),'linewidth',2)
    text(diff(xlim2)*.05+xlim2(1),diff(ylim2)*.33+ylim2(1),sprintf('p=%0.6f',pval(jj)))
    set(gca,'xlim',ylim1,'ylim',ylim2)
    set(gca,'ytick',[])
    set(gca,'XDir','reverse')
    camroll(-90)
    
end

%% classification accuracy phase 1
mrk_ = rfb_selectTrials(mrk{1},trial{1}.valid);
mrk_ = mrk_selectClasses(mrk_,{'trial start','movement onset'});
fv = proc_segmentation(cnt{1},mrk_,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_selectChannels(fv,trial{1}.clab);
warning off
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
warning on
fprintf('\nClassification accuracy phase 1: %2.1f%%\n',100*(1-loss))

%% classification accuracy phase 2
mrk_ = mrk_selectClasses(mrk{2},{'trial start','movement onset'});
fv = proc_segmentation(cnt{2},mrk_,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_selectChannels(fv,trial{1}.clab);
warning off
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
warning on
fprintf('\nClassification accuracy phase 2: %2.1f%%\n',100*(1-loss))


%% grid plot of RP difference between phases 1 and 2
epo = cell(2,1);
for jj = 1:2
    mrk_ = rfb_selectTrials(mrk{jj},trial{jj}.valid);
    mrk_ = mrk_selectClasses(mrk_,mo_classes{jj});
    epo{jj} = proc_segmentation(cnt{jj},mrk_,opt.cfy_rp.fv_window);
    epo{jj} = proc_baseline(epo{jj},opt.cfy_rp.ival_baseln);
    epo{jj}.className = phases(jj);
end
epo = proc_appendEpochs(epo{1},epo{2});
%%%
epo = proc_rejectArtifactsMaxMin(epo,150,'verbose',1,'Clab',clab_grid);
%%%
epo = proc_selectChannels(epo,clab_grid);
rsq = proc_rSquareSigned(epo);

fig_init(25,20);
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[1 1.8]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
for jj = 1:length(H.chan)
    if any(strcmp(H.chan(jj).ax_title.String,trial{2}.clab))
        set(H.chan(jj).ax_title,'FontWeight','bold')
    end
end




































