
subj_code = 'VPfar';

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
    [mrk{jj},trial{jj}] = rfb_removeOutliers(mrk{jj},trial{jj});
end
opt2 = rfb_getOptData(subj_code);

%% get acceleration variable
Acc_avg = cell(2,1);
Acc_max = cell(2,1);
for jj = 1:2
    mrk1 = mrk_selectClasses(mrk{jj},mo_classes{jj});
    Nt = length(mrk1.time);
    Acc_avg{jj} = zeros(Nt,1);
    Acc_max{jj} = zeros(Nt,1);
    t_mo2pp = trial{jj}.t_mo2pp(trial{jj}.valid);
    t_mo2pp = floor(t_mo2pp/10)*10;
    for ii = 1:Nt
        mrk2 = mrk_selectEvents(mrk1,ii);
        epo = proc_segmentation(cnt{jj},mrk2,[-100 t_mo2pp(ii)]);
        epo = proc_selectChannels(epo,'Acc*');
        epo = proc_baseline(epo,[-100 0]);
        epo = proc_selectIval(epo,[0 t_mo2pp(ii)]);
        Acc_avg{jj}(ii) = mean(mean(abs(epo.x)));
        Acc_max{jj}(ii) = max(max(abs(epo.x)));
    end
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
mrk_ = mrk_selectClasses(mrk{1},{'trial start','movement onset'});
fv = proc_segmentation(cnt{1},mrk_,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_selectChannels(fv,opt.cfy_rp.clab_base);
warning off
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
warning on
fprintf('\nClassification accuracy: %2.1f%%\n',100*(1-loss))

%% grid plot of RP difference between phases 1 and 2
mrk_ = mrk_selectClasses(mrk{1},mo_classes{1});
epo = proc_segmentation(cnt{1},mrk_,opt.cfy_rp.fv_window);
epo = proc_baseline(epo,opt.cfy_rp.ival_baseln);
epo.className = {'Phase1'};
mrk_ = mrk_selectClasses(mrk{2},mo_classes{2});
epo2 = proc_segmentation(cnt{2},mrk_,opt.cfy_rp.fv_window);
epo2 = proc_baseline(epo2,opt.cfy_rp.ival_baseln);
epo2.className = {'Phase2'};
epo = proc_appendEpochs(epo,epo2);
%%%
epo = proc_rejectArtifactsMaxMin(epo,150,'verbose',1,'Clab',clab_grid);
%%%
epo = proc_selectChannels(epo,clab_grid);
rsq = proc_rSquareSigned(epo);

fig_init(25,20);
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[1 1.8]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
for jj = 1:length(H.chan)
    if any(strcmp(H.chan(jj).ax_title.String,opt2.cfy_rp.clab))
        set(H.chan(jj).ax_title,'FontWeight','bold')
    end
end

%%
Y = [X{1,2}...
     X{2,2}...
     X{3,2}...
     trial{2}.time(trial{2}.valid)...
     Acc_avg{2}...
     Acc_max{2}];
T = array2table(Y);
T.Properties.VariableNames = {'C','WT','Vel','Time','Acc_avg','Acc_max'};
formula = 'C ~ 1 + Time + WT + Acc_max + Vel + Acc_avg';
lm = fitlm(T,formula);
disp(lm)




































