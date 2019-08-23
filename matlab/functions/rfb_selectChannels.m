
function [chan_sel,loss] = rfb_selectChannels(cnt,mrk,mnt)

%clab = {'FC3','FC1','FC2','FC4','C3','C1','Cz','C2','C4','F1','Fz','F2','CP1','CPz','CP2'};
clab = {'FC1','FC2','C1','Cz','C2','F1','Fz','F2','CP1','CPz','CP2'};

global opt
ival_amp = [-200 0];

epo = proc_segmentation(cnt,mrk,opt.ival_erp);
epo = proc_baseline(epo,opt.baseln_len,opt.baseln_pos);
%%
epo = proc_rejectArtifactsMaxMin(epo,100,'verbose',1,'Clab',clab);
%%
epo_ = proc_selectChannels(epo,clab);
rsq = proc_rSquareSigned(epo_,'Stats',1);
amp = proc_meanAcrossTime(epo_,ival_amp);

%% (i) sum of r-squared values must be larger than zero, and select all channels above median
sum_rsq = sum(rsq.x);
chanind_1 = sum_rsq>=median(sum_rsq) & sum_rsq>0;

%% (ii) RP+ amplitudes must be smaller than zero
[~,pval] = ttest(squeeze(amp.x(1,:,logical(amp.y(2,:))))',0,'tail','left');
chanind_2 = pval<.05;

%% (iii) RP+ amplitudes must be smaller than RP- amplitudes
[~,pval] = ttest2(squeeze(amp.x(1,:,logical(amp.y(2,:))))',...
    squeeze(amp.x(1,:,logical(amp.y(1,:))))',...
    'tail','left');
chanind_3 = pval<.05;

%% channel selection
chan_sel = epo_.clab(chanind_1&chanind_2&chanind_3);
%chan_sel = clab;

%% cross-validation
fv = proc_selectChannels(epo_,chan_sel);
fv = proc_jumpingMeans(fv,opt.ivals_fv);
loss = crossvalidation(fv,@train_RLDAshrink,...
                       'SampleFcn',@sample_leaveOneOut,...
                       'LossFcn',@loss_0_1);
fprintf('\nLeave-one-out classification accuracy: %2.2f%%\n',(1-loss)*100)

%% plot
figure
H = grid_plot(epo,mnt,'PlotStat','sem');
grid_addBars(rsq,'HScale',H.scale)
for jj = 1:length(H.chan)
    if any(strcmp(H.chan(jj).ax_title.String,chan_sel))
        set(H.chan(jj).ax_title,'FontWeight','bold')
    end
end

