
subj_code = {'VPfbe','VPfbf','VPfbg','VPfbh','VPfbi','VPfbj','VPfbk',...
             'VPfbl','VPfbm'};
Ns = length(subj_code);
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
alph = .01;

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

%% RP topology StageII
epo_ga_ = proc_selectClasses(epo_ga,[3 4]);
rsq_ga_ = rsq_ga;
rsq_ga_.x(rsq_ga_.p>alph) = 0;
rsq_ga_ = proc_selectClasses(rsq_ga_,12);
rfb_gridplot(epo_ga_,rsq_ga_,mnt)
figure
plot_scalpEvolution(rsq_ga_,mnt,[-300 0],defopt_scalp_r('ExtrapolateToZero',1));

%% Compare RPs in StageI and StageII
epo_ga_ = proc_selectClasses(epo_ga,[2 4]);
rsq_ga_ = rsq_ga;
rsq_ga_.x(rsq_ga_.p>alph) = 0;
rsq_ga_ = proc_selectClasses(rsq_ga_,8);
rfb_gridplot(epo_ga_,rsq_ga_,mnt)
figure
plot_scalpEvolution(rsq_ga_,mnt,[-300 0],defopt_scalp_r('ExtrapolateToZero',1));

%% Compare RPs in StageI and StageII/3rd tercile
epo_ga_ = proc_selectClasses(epo_ga,[2 7]);
rsq_ga_ = rsq_ga;
rsq_ga_.x(rsq_ga_.p>alph) = 0;
rsq_ga_ = proc_selectClasses(rsq_ga_,11);
rfb_gridplot(epo_ga_,rsq_ga_,mnt)
figure
plot_scalpEvolution(rsq_ga_,mnt,[-300 0],defopt_scalp_r('ExtrapolateToZero',1));

%%
epo_ga_ = proc_selectClasses(epo_ga,[2 5:7]);
rfb_gridplot(epo_ga_,[],mnt)

%%
ind = 9:11;
figure
for jj = 1:3
    rsq_ga_ = rsq_ga;
    rsq_ga_.x(rsq_ga_.p>.001) = 0;
    rsq_ga_ = proc_selectClasses(rsq_ga_,ind(jj));
    H = subplot(1,3,jj);
    plot_scalpEvolution(rsq_ga_,mnt,[-300 0],...
        defopt_scalp_r('ExtrapolateToZero',1),'Subplot',H,'CLim',[-.012 .012]);
end
    























