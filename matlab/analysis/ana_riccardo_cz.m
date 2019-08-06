%% preprocess
subj_code = 'VPfaf';
%Train the RP_Classifier with Cz, c1 and c2 only
opt.cfy_rp.clab = {'Cz', 'C1', 'C2'};
rfb_preprocessing(subj_code,'Phase1');
 
%% Get the phase1 COut
rfb_quickInspection(subj_code)

%% Get the phase2 COut using the classifier from phase1
%% First preprocess the Phase 2 data, so that it can have registered onset
rfb_preprocessing(subj_code,'Phase2');

%% get the markers for movement onset. 
[mrk,cnt,mnt] = rfb_loadData(subj_code,'Phase2');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==5);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'movement onset'});

%% Get COuts from phase2 based on the classifier on phase1
cnt_xv = proc_selectChannels(cnt,opt.cfy_rp.clab);
fv = proc_segmentation(cnt_xv,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);

cout_phase2 = apply_separatingHyperplane(opt.cfy_rp.C, fv.x).';

%% Preproceess phase22
rfb_preprocessing(subj_code,'Phase22');


%% Now for phase22
[mrk,cnt,mnt] = rfb_loadData(subj_code,'Phase22');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==5);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'movement onset'});

%% Get COuts from phase2 based on the classifier on phase1
cnt_xv = proc_selectChannels(cnt,opt.cfy_rp.clab);
fv = proc_segmentation(cnt_xv,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);

cout_phase2 = vertcat(cout_phase2, apply_separatingHyperplane(opt.cfy_rp.C, fv.x).');


%% Compare cout phase 1 and phase2
h1 = histfit(opt.feedback.pyff_params(3).phase1_cout.');
set(h1(1),'FaceAlpha', 0.5);
hold on
h2 = histfit(cout_phase2);
set(h2(1),'FaceAlpha', 0.5);
l=legend([h1(1) h2(1) ],'phase1','phase2');


%% box plots blocks
cout_phase1 = opt.feedback.pyff_params(3).phase1_cout.';
cout_block1 = cout_phase2(1:25);
cout_block2 = cout_phase2(26:75);
cout_block3 = cout_phase2(76:100);
cout_block4 = cout_phase2(101:125);
cout_block5 = cout_phase2(126:150);


x = [cout_phase1; cout_block1; cout_block2; cout_block3; cout_block4; cout_block5; cout_phase2];
g = [ones(size(cout_phase1)); 2*ones(size(cout_block1)); 3*ones(size(cout_block2));...
    4*ones(size(cout_block3)); 5*ones(size(cout_block4)); 6*ones(size(cout_block5));...
    7*ones(size(cout_phase2))];
figure 
subplot 413
label_name = {'phase1','free','spont./unaware','planned/aware','fast','slow','phase2'};
boxplot(x,g, 'labels', label_name) 
ylabel('Classifier Output (a.u)')


%% Student T Test stuff

%% initialize

ival_rp = [-1200 0];
ival_amp = [-200 0];
ci = 8; % Cz
block_name = {'phase1','free','spont./unaware','planned/aware','fast','slow'};

%% get data

[mrk,trial] = rfb_analyzeTrials(subj_code,'Phase1');
[~,cnt] = rfb_loadData(subj_code,'Phase1');
mrk = mrk_selectClasses(mrk,'movement onset');
erp = proc_segmentation(cnt,mrk,ival_rp);
erp = proc_baseline(erp,100,'beginning');
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
erp = proc_meanAcrossTime(erp,ival_amp,'Cz');
amp = squeeze(erp.x);
Amp = cat(1,Amp,amp(logical(trial.valid_mo)));
G = cat(1,G,trial.block_nr(logical(trial.valid_mo))+4);
Vel = cat(1,Vel,trial.t_mo2pp_on(logical(trial.valid_mo)));
WT = cat(1,WT,trial.t_ts2mo_off(logical(trial.valid_mo)));
C = cat(1,C,trial.cout(logical(trial.valid_mo)));




%% difference phase 1 vs. free
[~,pval] = ttest2(Amp(G==1),Amp(G==2)) %% amplitude: significant
[~,pval] = ttest2(C(G==1),C(G==2)) %% classifier w/ Fz: significant
[~,pval] = ttest2(cout_phase1,cout_block1) %% classifier w/o Fz: not significant
[~,pval] = ttest2(Vel(G==1),Vel(G==2)) %% velocity : significant
[~,pval] = ttest2(WT(G==1),WT(G==2)) %% waiting time: NOT significant

%% difference aware vs. unaware
[~,pval] = ttest2(Amp(G==3),Amp(G==4)) %% amplitude: significant
[~,pval] = ttest2(C(G==3),C(G==4)) %% classifier: NOT significant
[~,pval] = ttest2(cout_block2, cout_block3) %% classifier w/o Fz: significant
[~,pval] = ttest2(Vel(G==3),Vel(G==4)) %% velocity : significant
[~,pval] = ttest2(WT(G==3),WT(G==4)) %% waiting time: significant

%% difference fast vs. slow
[~,pval] = ttest2(Amp(G==5),Amp(G==6)) %% amplitude: NOT significant
[~,pval] = ttest2(C(G==5),C(G==6)) %% classifier: significant
[~,pval] = ttest2(cout_block4, cout_block5) %% classifier w/o Fz: not significant
[~,pval] = ttest2(Vel(G==5),Vel(G==6)) %% velocity: significant
[~,pval] = ttest2(WT(G==5),WT(G==6)) %% waiting time: NOT significant


%% Histift for C-out
figure ('Name', 'classifier output');

subplot 311
h_phase1 = histfit(cout_phase1);
hold on
h_block1 = histfit(cout_block1);
set(h_phase1(1),'FaceAlpha', 0.5);
set(h_block1(1),'FaceAlpha', 0.5);
l = legend([h_phase1(1) h_block1(1)], block_name{1},block_name{2});

subplot 312
h_block2 = histfit(cout_block2);
hold on
h_block3 = histfit(cout_block3);
set(h_block2(1),'FaceAlpha', 0.5);
set(h_block3(1),'FaceAlpha', 0.5);
l = legend([h_block2(1) h_block3(1)], block_name{3},block_name{4});

subplot 313
h_block4 = histfit(cout_block4);
hold on
h_block5 = histfit(cout_block5)
set(h_block4(1),'FaceAlpha', 0.5);
set(h_block5(1),'FaceAlpha', 0.5);
l = legend([h_block4(1) h_block5(1)], block_name{5},block_name{6});

%% histfit for amplitude 
figure('Name', 'Amplitude');

subplot 311
h_phase1_amp = histfit(Amp(G==1));
hold on
h_block1_amp = histfit(Amp(G==2));
set(h_phase1_amp(1),'FaceAlpha', 0.5);
set(h_block1_amp(1),'FaceAlpha', 0.5);
l = legend([h_phase1_amp(1) h_block1_amp(1)], block_name{1},block_name{2});

subplot 312
h_block2_amp = histfit(Amp(G==3));
hold on
h_block3_amp = histfit(Amp(G==4));
set(h_block2_amp(1),'FaceAlpha', 0.5);
set(h_block3_amp(1),'FaceAlpha', 0.5);
l = legend([h_block2_amp(1) h_block3_amp(1)], block_name{3},block_name{4});

subplot 313
h_block4_amp = histfit(Amp(G==5));
hold on
h_block5_amp = histfit(Amp(G==6))
set(h_block4_amp(1),'FaceAlpha', 0.5);
set(h_block5_amp(1),'FaceAlpha', 0.5);
l = legend([h_block4_amp(1) h_block5_amp(1)], block_name{5},block_name{6});




