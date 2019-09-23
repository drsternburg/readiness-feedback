
subj_code = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl'};
Ns = length(subj_code);
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};

%%
epo = cell(Ns,1);
rsq = cell(Ns,1);
for ii = 1:Ns
    
    [trial,mrk,cnt,mnt] = rfb_getData(subj_code{ii},1,0);
    epo{ii} = rfb_extractEpochs(trial,mrk,cnt);
    rsq{ii} = proc_rSquareSigned(epo{ii},'Stats',1);
    epo{ii} = proc_average(epo{ii},'Stats',1);
    
end
mnt = mnt_adaptMontage(mnt,clab_grid);

%%
%Average = 'arithmetic';
%Average = 'NWeighted';
Average = 'INVVARweighted';
epo_ga = proc_grandAverage(epo,'Stats',1,'Average',Average);
rsq_ga = proc_grandAverage(rsq,'Stats',1,'Average',Average);

%%
epo_ga_ = proc_selectClasses(epo_ga,[1 2]);
rsq_ga_ = proc_selectClasses(rsq_ga,1);
rsq_ga_.x(squeeze(rsq_ga_.p(:,:,1))>.01) = 0;
rfb_gridplot(epo_ga_,rsq_ga_,mnt)
























