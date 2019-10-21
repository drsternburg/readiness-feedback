
[~,cnt,mnt] = rfb_loadData(subjs_all{1},'Phase2');
cnt = proc_selectChannels(cnt,util_scalpChannels);
clab = cnt.clab;
W = zeros(length(clab),1);

Ns2 = length(subjs_all);

for ii = 1:Ns2
    
    opt2 = rfb_getOptData(subjs_all{ii});
    [~,ia] = intersect(clab,opt2.cfy_rp.clab);
    W(ia) = W(ia)+1;
    
end

fig_init(20,15);
mnt = mnt_adaptMontage(mnt,cnt);
H = plot_scalp(mnt,W,defopt_scalp_r('ExtrapolateToZero',1,'ShowLabels',1,...
    'CLim',[-Ns2 Ns2]),'Resolution',25);
set(H.cb,'Limits',[0 Ns2],'Ticks',2:2:Ns2,'Position',[.85 .12 .03 .75])
set(get(H.cb,'label'),'String','# Subjects')
