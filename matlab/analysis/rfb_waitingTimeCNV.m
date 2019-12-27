%% load the data
% this one uses [0 2000] from TS and MO
load /Users/vincentjonany/Desktop/Hypo_ts.mat

%% Only for phase 2 
threshold_wt = 3; %only get the trials that are less than this waiting time. 
clear rsqq;
clear epoq;
clear epoq_nontarget;
rsqq = cell(Ns, 1);
epoq = cell(Ns, 1);
epoq_nontarget = cell(Ns, 1);
for ii=1:Ns
    indices_wt = find(trial{ii}{2}.t_ts2mo(trial{ii}{2}.valid)/1000<threshold_wt);
    indices_wt_not = find(trial{ii}{2}.t_ts2mo(trial{ii}{2}.valid)/1000>=threshold_wt);
    epo_ = proc_selectClasses(epo{ii}, 'Idle Phase 2'); 
    epoq_nontarget{ii} = proc_selectEpochs(epo_, indices_wt_not); 
    epoq{ii} = proc_selectEpochs(epo_, indices_wt); 
%     rsqq{ii} = proc_rSquareSigned(epoq{ii},'Stats',1);
    epoq{ii} = proc_average(epoq{ii});
    epoq_nontarget{ii} = proc_average(epoq_nontarget{ii}); 
    epoq{ii} = proc_appendEpochs(epoq{ii}, epoq_nontarget{ii});
    epoq{ii}.y = [1 0;0 1];
    epoq{ii}.className = {'CNV Fast', 'CNV Slow'};
%     rsqq{ii} = proc_rSquareSigned(epoq{ii},'Stats',1);

end

%% average stuff

epoq_ga = proc_grandAverage(epoq,'Stats',1);
% rsqq_ga = proc_grandAverage(rsqq,'Stats',1);

%%
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
mnt2 = mnt_restrictMontage(mnt,clab_grid);
rfb_gridplot(epoq_ga,[],mnt);

%%
topo_ivals = [0 500; 500 1000; 1000 1500; 1500 2000];

% topo_ivals = [-1000 -666; -666 -333; -333 0];
plot_scalpEvolution(epoq_ga,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));

