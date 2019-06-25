

%% preprocess
BTB.Tp.Code = 'VPfae';
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

% This is in Cz area
epo_0 = epo.x(:,:,logical(epo.y(1,:)));
epo_1 = epo.x(:,:,~logical(epo.y(1,:)));
plot(mean(epo_0(:,8,:),3))
hold on
plot(mean(epo_1(:,8,:),3))
hold off
% This is on the Fz area 
figure
plot(mean(epo_0(:,7,:),3))
hold on
plot(mean(epo_1(:,7,:),3))
hold off

% RP VIz 
epo = proc_segmentation(cnt,mrk,[-1200 0]);
epo = proc_baseline(epo,200,'beginning');
rsq = proc_rSquareSigned(epo);


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
epo_phase1_1 = epo_phase1.x(:,:,~logical(epo_phase1.y(1,:)));

% Get the values of all the RP in phase 2
rp_block_1 = squeeze(epo_1(end, 8, 1:25));
rp_block_2 = squeeze(epo_1(end, 8, 25:50));
rp_block_3 = squeeze(epo_1(end, 8, 50:75));
rp_block_4 = squeeze(epo_1(end, 8, 75:end));
% RP from phase 1
rp_phase1 = squeeze(epo_phase1_1(end, 8, :));

h1 = histfit(rp_block_1);
set(h1(1),'FaceAlpha', 1);
hold on
h2=histfit(rp_block_2);
set(h2(1),'FaceAlpha', 1); 

h3=histfit(rp_block_3);
set(h3(1),'FaceAlpha', 1); 

h4=histfit(rp_block_4);
set(h4(1),'FaceAlpha', 1);

h5=histfit(rp_phase1);
set(h5(1),'FaceAlpha', 1);

l=legend([h1(1) h2(1) h3(1) h4(1) h5(1)],'block 1','block 2','block 3','block 4', 'phase1');
set(l,'Interpreter','latex','FontSize',14)
hold off




