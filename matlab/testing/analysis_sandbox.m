

%% preprocess
BTB.Tp.Code = 'VPfah';
rfb_convertBVData(BTB.Tp.Code,'Phase2');


%% Classifying stuff
[mrk,cnt,mnt] = rfb_loadData(BTB.Tp.Code,'Phase2');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);
mrk_movement = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk_movement = mrk_selectClasses(mrk_movement,{'trial start','pedal press'});

fv = proc_segmentation(cnt,mrk_movement,opt.cfy_acc.ival_fv);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);

%% set movement onset ACC on the second phase
rfb_initialCleanup(BTB.Tp.Code,'Phase2');
rfb_registerOnsets(BTB.Tp.Code,'Phase2');

%% Now I want to check the classifier on the second phase, and see the normal time distribution,
%% and RP too

[mrk,cnt,mnt] = rfb_loadData(BTB.Tp.Code,'Phase2');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==5);

mrk_movement = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk_movement =  mrk_selectClasses(mrk_movement,{'trial start','pedal press'});

mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});

cnt_xv = proc_selectChannels(cnt,opt.cfy_acc.clab);
fv = proc_segmentation(cnt_xv,mrk_movement,opt.cfy_acc.ival_fv);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);
% ACC
opt.cfy_acc.C = train_RLDAshrink(fv.x,fv.y);
[loss,~,cout] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
cout = cout(logical(fv.y(2,:)));
acc = 100*(1-loss);
fprintf('\nClassification accuracy: %2.1f\n',acc)

% RP 
cnt_xv = proc_selectChannels(cnt,opt.cfy_rp.clab);
fv = proc_segmentation(cnt_xv,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);

opt.cfy_rp.C = train_RLDAshrink(fv.x,fv.y);

fv = proc_flaten(fv);
[loss,~,cout] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
cout = cout(logical(fv.y(2,:)));
acc = 100*(1-loss);
fprintf('\nClassification accuracy: %2.1f\n',acc)
% Histogram waiting time
% 
% ci_emg = strcmp(mrk.className,'movement onset');
% ci_ts = strcmp(mrk.className,'trial start');
% i_emg = logical(mrk.y(logical(ci_emg),:));
% i_ts = logical(mrk.y(logical(ci_ts),:));
% 
% t_ts2emg = mrk.time(i_emg) - mrk.time(i_ts);
% 
% figure
% if verLessThan('matlab', '8.4')
%     hist(t_ts2emg/1000)
% else
%     histogram(t_ts2emg/1000)
% end
% xlabel('Waiting time (s)')
% ylabel('# counts')

% RP comparison VIZ on trial start and movement onset. 
epo = proc_segmentation(cnt,mrk,[-1200 0]);
epo = proc_baseline(epo,200,'beginning');

% This is in Cz area
epo_0 = epo.x(:,:,logical(epo.y(1,:)));
epo_1 = epo.x(:,:,~logical(epo.y(1,:)));
plot(mean(epo_0(:,12,:),3))
hold on
plot(mean(epo_1(:,12,:),3))
hold off
% This is on the Fz area 
figure
plot(mean(epo_0(:,11,:),3))
hold on
plot(mean(epo_1(:,11,:),3))
hold off

% RP VIz 
epo_viz = proc_segmentation(cnt,mrk,[-1200 0]);
epo_viz = proc_baseline(epo_viz,200,'beginning');
rsq = proc_rSquareSigned(epo_viz);


figure
H = grid_plot(epo,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);

%% Plotting distribution of all the readiness potential 

[mrk,cnt,mnt] = rfb_loadData(BTB.Tp.Code,'Phase1');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==4);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});

epo_phase1 = proc_segmentation(cnt,mrk,[-1200 0]);
epo_phase1 = proc_baseline(epo_phase1,200,'beginning');
epo_phase1_1 = epo_phase1.x(:,:,~logical(epo_phase1.y(1,:)));

% Get the values of all the RP in phase 2 
%The bad thing about this is that it is only in the Cz area, I need to have
%it in a more systematically. 
rp_phase2 = squeeze(epo_1(end, 12, :));

% RP from phase 1
rp_phase1 = squeeze(epo_phase1_1(end, 12, :));

h1 = histfit(rp_phase2);
set(h1(1),'FaceAlpha', 0.5);
hold on

h2=histfit(rp_phase1);
set(h2(1),'FaceAlpha', 0.5);

l=legend([h1(1) h2(1)], 'phase2', 'phase1');
set(l,'Interpreter','latex','FontSize',14)
hold off

%% Compare the pyff log of phase 2 with the amplitudes epo_1
L = rfb_getPyffLog(BTB.Tp.Code, 'phase2');
rp_matlab = squeeze(epo_1(end, 8, :));

h1 = histfit(rp_matlab);
set(h1(1),'FaceAlpha', 0.5);

hold on
h2 = histfit(L.cout);
set(h2(1),'FaceAlpha', 0.5);


l=legend([h1(1) h2(1) ],'RP matlab','C-out pyff');
hold off

% h3 = histfit(L.feedback);


% KStest also tests the differences in variances
[a, hypo_rp_cout] = kstest2(rp_matlab, L.cout); %significant
[b, hypo_cout_feedback] = kstest2(L.cout, L.feedback);%significant
[c, hypo_rp_feedback] = kstest2(rp_matlab, L.feedback);%significant


[d, t_test_rp_cout] = ttest2(rp_matlab, L.cout);%significant
[e, t_test_cout_feedback] = ttest2(L.cout, L.feedback);%significant
[f, t_test_rp_feedback] = ttest2(rp_matlab, L.feedback);%significant



sprintf('%f, %f ,%f ,%f, %f, %f', hypo_rp_cout, hypo_cout_feedback, hypo_rp_feedback...
    ,t_test_rp_cout, t_test_cout_feedback, t_test_rp_feedback)

%% Compare time diff from pyff and matlab classifier
[mrk,cnt,mnt] = rfb_loadData(BTB.Tp.Code,'Phase2');
trial_mrk = rfb_getTrialMarkers(mrk);
trial_mrk = trial_mrk(cellfun(@length,trial_mrk)==5);

mrk_movement = mrk_selectEvents(mrk,[trial_mrk{:}]);
mrk_movement =  mrk_selectClasses(mrk_movement,{'movement onset','pedal press'});

time_pedal = mrk_movement.time(logical(mrk_movement.y(2,:)));
time_movement_onset = mrk_movement.time(logical(mrk_movement.y(1,:)));

time_diff_pyff = L.t_mo2pp;
time_diff_pyff(find(time_diff_pyff < 0)) = []; %TODO: remove ones that are 3.5 SD away from mean. 

h1 = histfit(time_pedal - time_movement_onset);
set(h1(1),'FaceAlpha', 0.5);
hold on
h2 = histfit(time_diff_pyff);
set(h2(1),'FaceAlpha', 0.5);

l=legend([h1(1) h2(1) ],'time diff matlab','time diff pyff');

hold off
