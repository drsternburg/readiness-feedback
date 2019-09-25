
[mrk,cnt] = rfb_loadData('VPfad','Phase1');
cnt = proc_selectChannels(cnt,opt.cfy_rp.clab);
mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});
fv = proc_segmentation(cnt,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
[loss1,~,cout1] = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
cout1 = cout1(logical(fv.y(2,:)));
fv = proc_flaten(fv);
C = train_RLDAshrink(fv.x,fv.y);

%%
[mrk,cnt] = rfb_loadData('VPfad','Phase2');
cnt = proc_selectChannels(cnt,opt.cfy_rp.clab);
mrk = mrk_selectClasses(mrk,'movement onset');
fv = proc_segmentation(cnt,mrk,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.ival_baseln);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);
cout2 = zeros(size(fv.x,1),1);
for ii = 1:size(fv.x,1)
    cout2(ii) = apply_separatingHyperplane(C,fv.x(:,ii));
end

%%
L = rfb_getPyffLog('VPfad','Phase2');

%%
xlim = [-25 15];
figure

subplot 311, hold on
histogram(cout1)
set(gca,'xlim',xlim)

subplot 312, hold on
histogram(cout2)
set(gca,'xlim',xlim)

subplot 313, hold on
histogram(L.cout)
set(gca,'xlim',xlim)