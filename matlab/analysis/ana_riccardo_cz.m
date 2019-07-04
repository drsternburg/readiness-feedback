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
cout_block2 = cout_phase2(26:50);
cout_block3 = cout_phase2(51:75);
cout_block4 = cout_phase2(76:100);
cout_block5 = cout_phase2(101:125);
cout_block6 = cout_phase2(126:150);


x = [cout_phase1; cout_block1; cout_block2; cout_block3; cout_block4; cout_block5; cout_block6; cout_phase2];
g = [ones(size(cout_phase1)); 2*ones(size(cout_block1)); 3*ones(size(cout_block2));...
    4*ones(size(cout_block3)); 5*ones(size(cout_block4)); 6*ones(size(cout_block5));...
    7*ones(size(cout_block6)); 8*ones(size(cout_phase2))];
subplot 413
label_name = {'phase1', 'block1','block2', 'block3', 'block4', 'block5', 'block6', 'phase2'};
boxplot(x,g, 'labels', label_name) 
ylabel('Classifier Output (a.u)')


