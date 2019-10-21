
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
mnts = mnt_adaptMontage(mnt,clab_grid);
alph = .001;

topo_ivals = [-900 -600; -600 -300; -300 0];

%% Compare RPs against flat
ci = [2 4];
erp = cell(Ns,1);
rsq = cell(Ns,1);
for ii = 1:Ns
    erp_ = cell(2,1);
    rsq_ = cell(2,1);
    for jj = 1:2
        epo_ = proc_selectClasses(epo{ii},ci(jj));
        rsq_{jj} = proc_rSquareSigned(epo_,'Stats',1);
        erp_{jj} = proc_average(epo_,'Stats',1);
    end
    erp{ii} = proc_appendEpochs(erp_);
    rsq{ii} = proc_appendEpochs(rsq_);
end

%Average = 'arithmetic';
Average = 'NWeighted';
erp_ga = proc_grandAverage(erp,'Stats',1,'Average',Average);
rsq_ga = proc_grandAverage(rsq,'Stats',1,'Average',Average);

%% RP topologies

clim = [-.08 .08];

erp_ga_ = proc_selectClasses(erp_ga,1);
rsq_ga_ = rsq_ga;
rsq_ga_.x(rsq_ga_.p>alph) = 0;
rsq_ga_ = proc_selectClasses(rsq_ga_,1);

rfb_gridplot(erp_ga_,rsq_ga_,mnt)

figure
plot_scalpEvolution(rsq_ga_,mnt,topo_ivals,...
    defopt_scalp_r('ExtrapolateToZero',1,'CLim',clim,'ContourPolicy','withinrange'));


%%
erp_ga_ = proc_selectClasses(erp_ga,2);
rsq_ga_ = rsq_ga;
rsq_ga_.x(rsq_ga_.p>alph) = 0;
rsq_ga_ = proc_selectClasses(rsq_ga_,2);

rfb_gridplot(erp_ga_,rsq_ga_,mnt)

figure
plot_scalpEvolution(rsq_ga_,mnt,topo_ivals,...
    defopt_scalp_r('ExtrapolateToZero',1,'CLim',clim,'ContourPolicy','withinrange'));


%% Compare difference
erp = cell(Ns,1);
for ii = 1:Ns
    erp_1 = proc_selectClasses(epo{ii},2);
    erp_1 = proc_average(erp_1,'Stats',1);
    erp_2 = proc_selectClasses(epo{ii},4);
    erp_2 = proc_average(erp_2,'Stats',1);
    erp{ii} = erp_1;
    erp{ii}.x = erp_1.x - erp_2.x;
    erp{ii}.className = {'RP Phase 1 - RP Phase 2'};
end

Average = 'arithmetic';
%Average = 'NWeighted';
erp_ga = proc_grandAverage(erp,'Stats',1,'Average',Average);

rfb_gridplot(erp_ga,[],mnts)

figure
plot_scalpEvolution(erp_ga,mnts,topo_ivals,...
    defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));














