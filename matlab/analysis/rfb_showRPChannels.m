
% subj_code = {'VPfah','VPfai','VPfaj','VPfak','VPfal','VPfam','VPfan',...
%              'VPfao','VPfap','VPfaq','VPfar','VPfas','VPfat','VPfau',...
%              'VPfav','VPfaw','VPfax','VPfay','VPfaz','VPfba'};
% subj_code(strcmp(subj_code,'VPfam')) = []; % exclude VPfam due to very noisy data
% subj_code(strcmp(subj_code,'VPfal')) = []; % exclude VPfal due to very short WTs

%%
subj_code = {'VPfbe','VPfbf'};

%%
Ns = length(subj_code);
phase = 'Phase2';
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};

[~,cnt,mnt] = rfb_loadData(subj_code{1},phase);
cnt = proc_selectChannels(cnt,util_scalpChannels);
clab = cnt.clab;
W = zeros(length(clab),1);

for ii = 1:Ns
    
    opt2 = rfb_getOptData(subj_code{ii});
    [~,ia] = intersect(clab,opt2.cfy_rp.clab);
    W(ia) = W(ia)+1;
    
end

%%
fig_init(20,15);
mnt = mnt_adaptMontage(mnt,cnt);
H = plot_scalp(mnt,W,defopt_scalp_r('ExtrapolateToZero',1,'ShowLabels',1,...
    'CLim',[-Ns Ns]));
set(H.cb,'Limits',[0 Ns],'Ticks',1:2:Ns)
