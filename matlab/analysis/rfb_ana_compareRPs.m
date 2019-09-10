
subj_code = {'VPfah','VPfai','VPfaj','VPfak','VPfal','VPfam','VPfan',...
             'VPfao','VPfap','VPfaq','VPfar','VPfas','VPfat','VPfau',...
             'VPfav','VPfaw'};
subj_code(strcmp(subj_code,'VPfam')) = []; % exclude VPfam due to very noisy data
subj_code(strcmp(subj_code,'VPfal')) = []; % exclude VPfal due to very short WTs
subj_code(strcmp(subj_code,'VPfar')) = []; % CHECK!!!
subj_code(strcmp(subj_code,'VPfas')) = []; % exclude VPfas due to very noisy data
Ns = length(subj_code);

%%
phases = {'Phase2','Phase2'};
className = {'RP Phase1','RP Phase 2'};
mo_classes = {'movement onset','mo online'};

%%
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};

%%
epo = cell(Ns,1);
rsq = cell(Ns,1);
for ii = 1:Ns
    cnt = cell(2,1);
    mrk = cell(2,1);
    trial = cell(2,1);
    for jj = 1:2
        [mrk{jj},trial{jj}] = rfb_analyzeTrials(subj_code{ii},phases{jj});
        [~,cnt{jj},mnt] = rfb_loadData(subj_code{ii},phases{jj});
        cnt{jj} = proc_selectChannels(cnt{jj},clab_grid);
        %%%
        %pca = proc_pca(cnt{jj});
        %cnt{jj} = proc_regressOutComponents(cnt{jj},pca.x(:,1));
        %%%
        trial{jj} = rfb_removeOutliers(trial{jj});
        trial{jj} = rfb_removeArtifacts(trial{jj},mrk{jj},cnt{jj},mo_classes{jj});
    end
    
    %%
    epo2 = cell(2,1);
    for jj = 1:2
        mrk_ = rfb_selectTrials(mrk{jj},trial{jj}.valid);
        mrk_ = mrk_selectClasses(mrk_,mo_classes{jj});
        epo2{jj} = proc_segmentation(cnt{jj},mrk_,opt.cfy_rp.fv_window);
        epo2{jj} = proc_baseline(epo2{jj},opt.cfy_rp.ival_baseln);
        %%%
        epo2{jj} = proc_rejectArtifactsMaxMin(epo2{jj},150,'verbose',1,'Clab',clab_grid);
        %%%
        epo2{jj}.className = className(jj);
    end
    epo{ii} = proc_appendEpochs(epo2{1},epo2{2});
    rsq{ii} = proc_rSquareSigned(epo{ii},'Stats',1);
    epo{ii} = proc_average(epo{ii},'Stats',1);
    
end

%%
Average = 'arithmetic';
epo_ga = proc_grandAverage(epo,'Stats',1,'Average',Average);
rsq_ga = proc_grandAverage(rsq,'Stats',1,'Average',Average);

%%
mnt = mnt_adaptMontage(mnt,clab_grid);
fig_init(25,20);
H = grid_plot(epo_ga,mnt,'PlotStat','sem','ShrinkAxes',[1 1.8]);
grid_addBars(rsq_ga,'HScale',H.scale,'Height',1/7);



































