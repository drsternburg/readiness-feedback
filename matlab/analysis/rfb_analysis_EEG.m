
subj_code = 'VPfbb';

[trial,mrk,cnt,mnt] = rfb_getData(subj_code,1,0);

clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
clab_selected = trial{1}.clab;
mnt = mnt_adaptMontage(mnt,clab_grid);

%%
epo = rfb_extractEpochs(trial,mrk,cnt);

%%
cls_xval = {'TS Phase1','MO Phase1';...
            'TS Phase2','MO Phase2';...
            'TS Phase1','MO Phase2';...
            'MO Phase1','MO Phase2'};
Nc = size(cls_xval,1);

%%
cout = cell(Nc,1);
fprintf('\n')
for jj = 1:Nc
    fv = proc_selectClasses(epo,cls_xval(jj,:));
    fv = proc_selectChannels(fv,clab_selected);
    fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);    
    warning off
    [~,~,cout{jj}] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
    loss = mean(loss_classwiseNormalized(fv.y,cout{jj}));
    cout{jj} = cout{jj}(logical(fv.y(2,:)));
    warning on
    fprintf('%s vs %s: %2.1f%%\n',cls_xval{jj,1},cls_xval{jj,2},100*(1-loss))
end

%%
for jj = 1:Nc
    epo_ = proc_selectClasses(epo,cls_xval(jj,:));
    rsq = proc_rSquareSigned(epo_);
    rfb_gridplot(epo_,rsq,mnt,clab_selected)
end

%%
epo_ = proc_selectClasses(epo,'MO Phase2');
Nh = floor(size(epo_.x,3)/2);
epo_h1 = proc_selectEpochs(epo_,1:Nh);
epo_h1.className = {'MO Phase2 first half'};
epo_h2 = proc_selectEpochs(epo_,Nh+1:size(epo_.x,3));
epo_h2.className = {'MO Phase2 second half'};
epo_ = proc_appendEpochs(epo_h1,epo_h2);
rsq = proc_rSquareSigned(epo_);
rfb_gridplot(epo_,rsq,mnt,clab_selected)

%%
epo_ = proc_selectClasses(epo,'MO Phase2');
cout = trial{2}.cout(trial{2}.valid);
[~,si] = sort(cout);
epo_h1 = proc_selectEpochs(epo_,si(1:round(length(si)/2)));
epo_h1.className = {'MO Phase2 low cout'};
epo_h2 = proc_selectEpochs(epo_,si(round(length(si)/2)+1:length(si)));
epo_h2.className = {'MO Phase2 high cout'};
epo_ = proc_appendEpochs(epo_h1,epo_h2);
rsq = proc_rSquareSigned(epo_);
rfb_gridplot(epo_,rsq,mnt,clab_selected)

%%
epo_ = proc_selectClasses(epo,'MO Phase2');
cout = trial{2}.cout(trial{2}.valid);
[~,si] = sort(cout);
Nc = length(cout);
edges = [1 round(Nc/3) round(Nc/3)*2 Nc];
epo2{1} = proc_selectEpochs(epo_,si(edges(1):edges(2)));
epo2{1}.className = {'MO Phase2 low cout'};
epo2{2} = proc_selectEpochs(epo_,si(edges(2):edges(3)));
epo2{2}.className = {'MO Phase2 mid cout'};
epo2{3} = proc_selectEpochs(epo_,si(edges(3):edges(4)));
epo2{3}.className = {'MO Phase2 high cout'};
epo_ = proc_appendEpochs(epo2);
rsq = proc_rSquareSigned(epo_);
rfb_gridplot(epo_,rsq,mnt,clab_selected)






























