
function trial = rfb_flagArtifacts(trial,mrk,cnt,mo_class)

global opt

mrk_ = mrk_selectClasses(mrk,mo_class);
epo = proc_segmentation(cnt,mrk_,opt.cfy_rp.fv_window);
[~,ind] = proc_rejectArtifactsMaxMin(epo,150,'Clab',trial.clab);
fprintf('%d trials with artifacts flagged\n',length(ind))

if not(isempty(ind))
    trial.valid(ind) = false;
end



































