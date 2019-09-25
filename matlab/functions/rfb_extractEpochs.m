
function epo = rfb_extractEpochs(trial,mrk,cnt)

global opt

cls_nfo = {1,'trial start','TS Phase1';...
           1,'movement onset','MO Phase1';...
           2,'trial start','TS Phase2';...
           2,'mo online','MO Phase2';...
           2,'mo online','MO Phase2.1';...
           2,'mo online','MO Phase2.2';...
           2,'mo online','MO Phase2.3'};
blk_nfo = reshape(1:12,4,3);

Nc = size(cls_nfo,1);
epo = cell(Nc,1);

for jj = 1:4
    mrk_ = rfb_selectTrials(mrk{cls_nfo{jj,1}},trial{cls_nfo{jj,1}}.valid);
    mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj,2});
    epo{jj} = proc_segmentation(cnt{cls_nfo{jj,1}},mrk_,opt.cfy_rp.fv_window);
    epo{jj} = proc_baseline(epo{jj},opt.cfy_rp.ival_baseln);
    epo{jj}.className = cls_nfo(jj,3);    
end
for jj = 5:7
    ind = trial{cls_nfo{jj,1}}.valid &...
          ismember(trial{cls_nfo{jj,1}}.block_nr,blk_nfo(:,jj-4));
    mrk_ = rfb_selectTrials(mrk{cls_nfo{jj,1}},ind);
    mrk_ = mrk_selectClasses(mrk_,cls_nfo{jj,2});
    epo{jj} = proc_segmentation(cnt{cls_nfo{jj,1}},mrk_,opt.cfy_rp.fv_window);
    epo{jj} = proc_baseline(epo{jj},opt.cfy_rp.ival_baseln);
    epo{jj}.className = cls_nfo(jj,3);    
end

epo = proc_appendEpochs(epo);