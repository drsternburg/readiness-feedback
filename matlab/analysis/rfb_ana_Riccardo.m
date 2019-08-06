
subj_code = 'VPfaf';
ival_rp = [-1200 1000];
ival_amp = [-500 0];
ci = 8; % Cz
block_name = {'phase1','free','spontaneous','planned','fast','slow'};
alph = .05;

%% get data
rp = [];

[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase1');
[~,cnt,mnt] = rfb_loadData(subj_code,'Phase1');
mrk = mrk_selectClasses(mrk,'movement onset');
%%%
%mrk.time = mrk.time-100;
%%%
erp = proc_segmentation(cnt,mrk,ival_rp);
erp = proc_baseline(erp,100,'beginning');
rp = proc_appendEpochs(rp,erp);

rsq = proc_rSquareSigned(rp,'Stats',1);
spat_flt = zeros(size(rsq.x));
spat_flt(rsq.sgnlogp<log(alph)) = 1;
spat_flt = spat_flt(:);

amp2 = reshape(erp.x,size(erp.x,1)*size(erp.x,2),size(erp.x,3));
amp2 = sum(amp2(logical(spat_flt),:),1);
Amp2 = amp2';
erp = proc_meanAcrossTime(erp,ival_amp,'Cz');
Amp = squeeze(erp.x);
G = ones(length(Amp),1);
Vel = trial.t_mo2pp_off(logical(trial.valid_mo));
WT = trial.t_ts2mo_off(logical(trial.valid_mo));

opt2 = rfb_getOptData(subj_code);
C = opt2.opt.feedback.pyff_params(4).phase1_cout';

[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase2');
[~,cnt] = rfb_loadData(subj_code,'Phase2');
mrk = mrk_selectClasses(mrk,'movement onset');
erp = proc_segmentation(cnt,mrk,ival_rp);
erp = proc_baseline(erp,100,'beginning');
rp = proc_appendEpochs(rp,erp);
amp2 = reshape(erp.x,size(erp.x,1)*size(erp.x,2),size(erp.x,3));
amp2 = sum(amp2(logical(spat_flt),:),1);
Amp2 = cat(1,Amp2,amp2(logical(trial.valid_mo))');
erp = proc_meanAcrossTime(erp,ival_amp,'Cz');
amp = squeeze(erp.x);
Amp = cat(1,Amp,amp(logical(trial.valid_mo)));
g = trial.block_nr(logical(trial.valid_mo));
g(g==1) = 2;
G = cat(1,G,g);
Vel = cat(1,Vel,trial.t_mo2pp_on(logical(trial.valid_mo)));
WT = cat(1,WT,trial.t_ts2mo_off(logical(trial.valid_mo)));
C = cat(1,C,trial.cout(logical(trial.valid_mo)));

[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase22');
[~,cnt] = rfb_loadData(subj_code,'Phase22');
mrk = mrk_selectClasses(mrk,'movement onset');
erp = proc_segmentation(cnt,mrk,ival_rp);
erp = proc_baseline(erp,100,'beginning');
rp = proc_appendEpochs(rp,erp);
amp2 = reshape(erp.x,size(erp.x,1)*size(erp.x,2),size(erp.x,3));
amp2 = sum(amp2(logical(spat_flt),:),1);
Amp2 = cat(1,Amp2,amp2(logical(trial.valid_mo))');
erp = proc_meanAcrossTime(erp,ival_amp,'Cz');
amp = squeeze(erp.x);
Amp = cat(1,Amp,amp(logical(trial.valid_mo)));
G = cat(1,G,trial.block_nr(logical(trial.valid_mo))+4);
Vel = cat(1,Vel,trial.t_mo2pp_on(logical(trial.valid_mo)));
WT = cat(1,WT,trial.t_ts2mo_off(logical(trial.valid_mo)));
C = cat(1,C,trial.cout(logical(trial.valid_mo)));

rp.y = zeros(6,length(rp.y));
for jj = 1:6
    rp.y(jj,G==jj) = 1;
end
rp.className = block_name;

[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase1');
[~,cnt,mnt] = rfb_loadData(subj_code,'Phase1');
mrk = mrk_selectClasses(mrk,'trial start');
erp = proc_segmentation(cnt,mrk,ival_rp);
erp = proc_baseline(erp,100,'beginning');
rp = proc_appendEpochs(rp,erp);

%% box plots
fig_init(20,30);

subplot 411
boxplot(C,G,'labels',block_name)
ylabel('Classifier output (a.u.)')
set(gca,'ygrid','on')
%anova1(C,G,'off')

subplot 412
boxplot(Amp,G,'labels',block_name)
ylabel('RP amplitude (\muV)')
set(gca,'ygrid','on')
%anova1(Amp,G,'off')

subplot 413
boxplot(Vel,G,'labels',block_name)
ylabel('Movement velocity (ms)')
set(gca,'ygrid','on')
%anova1(Vel,G,'off')

subplot 414
boxplot(WT/1000,G,'labels',block_name)
ylabel('Waiting time (sec)')
set(gca,'ygrid','on')
%anova1(WT,G,'off')

%% difference phase 1 vs. free
[~,pval] = ttest2(Amp(G==1),Amp(G==2)) %% amplitude: significant
[~,pval] = ttest2(C(G==1),C(G==2)) %% classifier: significant
[~,pval] = ttest2(Vel(G==1),Vel(G==2)) %% velocity : significant
[~,pval] = ttest2(WT(G==1),WT(G==2)) %% waiting time: NOT significant

%% difference aware vs. unaware
[~,pval] = ttest2(Amp(G==3),Amp(G==4)) %% amplitude: significant
[~,pval] = ttest2(C(G==3),C(G==4)) %% classifier: NOT significant
[~,pval] = ttest2(Vel(G==3),Vel(G==4)) %% velocity : significant
[~,pval] = ttest2(WT(G==3),WT(G==4)) %% waiting time: significant

%% difference fast vs. slow
[~,pval] = ttest2(Amp(G==5),Amp(G==6)) %% amplitude: NOT significant
[~,pval] = ttest2(C(G==5),C(G==6)) %% classifier: significant
[~,pval] = ttest2(Vel(G==5),Vel(G==6)) %% velocity: significant
[~,pval] = ttest2(WT(G==5),WT(G==6)) %% waiting time: NOT significant

%%
fig_init(30,20);
rp_ = proc_selectClasses(rp,[1 2]);
rsq = proc_rSquareSigned(rp_,'Stats',1);
H = grid_plot(rp_,mnt);
grid_addBars(rsq,'HScale',H.scale)











