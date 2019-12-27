%% load the data

load /Users/vincentjonany/Desktop/Hypo_ts.mat

%%
epoq = cell(Ns, 1);
rsqq = cell(Ns, 1);

for ii = 1:Ns
    epoq{ii} = proc_selectClasses(epo{ii}, {'RP Phase 1','RP Phase 2'});
    rsqq{ii} = proc_rSquareSigned(epoq{ii},'Stats',1);
    epoq{ii} = proc_average(epoq{ii},'Stats',1);
end


epoq_ga = proc_grandAverage(epoq,'Stats',1);
rsqq_ga = proc_grandAverage(rsqq,'Stats',1);

%%
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
mnt2 = mnt_restrictMontage(mnt,clab_grid);
rfb_gridplot(epoq_ga,[],mnt);

%%
% topo_ivals = [-550 -525; -525 -500; -500 -475; -475 -450];
topo_ivals = [0 1000; 1000 2000];

% topo_ivals = [-1000 -666; -666 -333; -333 0];

%     subplot(2, 4, ii);
plot_scalpEvolution(epoq_ga,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));

%%
epo_mo = proc_selectClasses(epo{1}, {'RP Phase 1', 'RP Phase 2'});
rsq_mo = proc_rSquareSigned(epo_mo);
topo_ivals = [0 500; 500 1000; 1000 1500; 1500 2000];
plot_scalpEvolution(rsq_mo,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));
