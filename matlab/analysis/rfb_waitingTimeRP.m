%% load the data
% this one uses [-1000 0] from MO and TS
load /Users/vincentjonany/Desktop/Hypo.mat

%% RP Phase 2

cname = {'RP Q1','RP Q2','RP Q3'};
Np = size(cname, 2);
rsqq = cell(Ns, Np);
epoq = cell(Ns, Np);
avg_wt = cell(3,1);

for ii=1:Ns
    wts = trial{ii}{1}.t_ts2mo(trial{ii}{1}.valid);
    [~, si] = sort(wts);
    epo_ = proc_selectClasses(epo{ii}, 'RP Phase 1');
    edges = [1 round(size(wts,1)/Np*(1:Np))];
    
    for jj=1:Np
        avg_wt{jj} = vertcat(avg_wt{jj}, wts(si(edges(jj):edges(jj+1))));
        epo_temp = proc_selectEpochs(epo_, si(edges(jj):edges(jj+1)));
        epo_temp.className = cname(jj);
        if jj==1
            epo_q1 = epo_temp;
        end
        if jj == 3
            epo_interest = proc_appendEpochs(epo_temp, epo_q1);
            rsqq{ii, jj} =  proc_rSquareSigned(epo_interest,'Stats',1);
        else
            rsqq{ii, jj} = proc_rSquareSigned(epo_temp,'Stats',1);
        end
        epoq{ii, jj} = proc_average(epo_temp,'Stats',1);
    end
    
 
end
%%
clear epoq_ga;
clear rsqq_ga;
epoq_ga = cell(Np,1);
rsqq_ga = cell(Np,1);
for jj = 1:Np
    epoq_ga{jj} = proc_grandAverage(epoq(:,jj),'Stats',1);
    rsqq_ga{jj} = proc_grandAverage(rsqq(:,jj),'Stats',1);
end
epoq_ga = proc_appendEpochs(epoq_ga);
rsqq_ga = proc_appendEpochs(rsqq_ga);
%%C
% clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
% mnt = mnt_restrictMontage(mnt,clab_grid);
% rfb_gridplot(proc_selectClasses(epoq_ga, 3),[],mnt);

%%
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
mnt = mnt_restrictMontage(mnt,clab_grid);
epoq_interest = proc_selectClasses(epoq_ga, {'RP Q1', 'RP Q3'});
rsqq_int = proc_selectClasses(rsqq_ga , 3);
rfb_gridplot(epoq_interest,rsqq_int,mnt);


%%
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[.9 .9]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);

%%

topo_ivals = [-1000 -666; -666 -333; -333 0];
plot_scalpEvolution(epoq_ga,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));




%% Phase 1 VS phase 2

cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = size(cname, 2);
rsqq = cell(Ns, Np);
epoq1 = cell(Ns, Np);
epoq2 = cell(Ns, Np);
wts1_all = [];
wts2_all = [];

for ii=1:Ns
    wts1 = trial{ii}{1}.t_ts2mo(trial{ii}{1}.valid);
    wts2 = trial{ii}{2}.t_ts2mo(trial{ii}{2}.valid);
    [~, si1] = sort(wts1);
    [~, si2] = sort(wts2);
    wts1_all = vertcat(wts1_all, wts1);
    wts2_all = vertcat(wts2_all, wts2);
    epo_p1 = proc_selectClasses(epo{ii}, 'RP Phase 1');
    epo_p2 = proc_selectClasses(epo{ii}, 'RP Phase 2');

    edges1 = [1 round(size(wts1,1)/Np*(1:Np))];
    edges2 = [1 round(size(wts2,1)/Np*(1:Np))];

    for jj=1:Np
        epo_temp1 = proc_selectEpochs(epo_p1, si1(edges1(jj):edges1(jj+1)));
        epo_temp2 = proc_selectEpochs(epo_p2, si2(edges2(jj):edges2(jj+1)));
        
        epo_temp1.className = {['P1 ' cname{jj}]};
        epo_temp2.className = {['P2 ' cname{jj}]};
        
        rsqq{ii,jj} = proc_rSquareSigned(proc_appendEpochs(epo_temp1, epo_temp2),'Stats',1);
        
        epoq1{ii, jj} = proc_average(epo_temp1,'Stats',1);
        epoq2{ii, jj} = proc_average(epo_temp2,'Stats',1);

    end
    
 
end

%% Averaging
clear epoq_ga;
clear rsqq_ga;
epoq_ga1 = cell(Np,1);
epoq_ga2 = cell(Np,1);
rsqq_ga = cell(Np,1);
for jj = 1:Np
    epoq_ga1{jj} = proc_grandAverage(epoq1(:,jj),'Stats',1);
    epoq_ga2{jj} = proc_grandAverage(epoq2(:,jj),'Stats',1);
    rsqq_ga{jj} = proc_grandAverage(rsqq(:,jj),'Stats',1);
end
epoq_ga1 = proc_appendEpochs(epoq_ga1);
epoq_ga2 = proc_appendEpochs(epoq_ga2);
rsqq_ga = proc_appendEpochs(rsqq_ga);

%%
% clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
% mnt = mnt_restrictMontage(mnt,clab_grid);
rfb_gridplot(rsqq_ga,[],mnt);

%%
rfb_gridplot(epoq_ga2,[],mnt);

%%

topo_ivals = [-1000 -666; -666 -333; -333 0];
plot_scalpEvolution(epoq_ga2,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));



%% eeg p1 p2 individuals
classnames1 = {'P1 RP Q1'  'P1 RP Q2'  'P1 RP Q3'  'P1 RP Q4'};
classnames2 = {'P2 RP Q1'  'P2 RP Q2'  'P2 RP Q3'  'P2 RP Q4'};
p1_p2 = cell(4,1);
for kk=1:4
    p1 = proc_selectClasses(epoq_ga1, classnames1{kk});
    p2 = proc_selectClasses(epoq_ga2, classnames2{kk});
    p1_p2{kk} = proc_appendEpochs(p1, p2);
end

%%
rfb_gridplot(p1_p2{4},[],mnt);

%%
topo_ivals = [-1000 -666; -666 -333; -333 0];
p1_p2_all = proc_appendEpochs(p1_p2);
plot_scalpEvolution(p1_p2_all,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));



%% Not per subject but as a whole. 

all_wts = cell(Ns, 1);
all_wts{1} = trial{1}{2}.t_ts2mo(trial{1}{2}.valid);
all_epo = proc_selectClasses(epo{1}, 'RP Phase 2');
for ii=2:Ns
    all_wts{ii} = trial{ii}{2}.t_ts2mo(trial{ii}{1}.valid);
    epo_ = proc_selectClasses(epo{ii}, 'RP Phase 2');
    all_epo = proc_appendEpochs(all_epo, epo_);
end

all_wts = vertcat(all_wts{:}); 
[~, si] = sort(all_wts);
cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = size(cname, 2);
rsqq = cell(Np, 1);
epoq = cell(Np, 1);

edges = [1 round(size(all_wts,1)/Np*(1:Np))];
for ii=1:Np
    epoq{ii} = proc_selectEpochs(all_epo, si(edges(ii):edges(ii+1)));
    epoq{ii}.className = cname(ii);
    rsqq{ii} = proc_rSquareSigned(epoq{ii},'Stats',1);
    epoq{ii} = proc_average(epoq{ii},'Stats',1);
end
%%
clear epoq_ga;
clear rsqq_ga;
epoq_ga = proc_appendEpochs(epoq);
rsqq_ga = proc_appendEpochs(rsqq);

%%
% clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
% mnt = mnt_restrictMontage(mnt,clab_grid);
rfb_gridplot(epoq_ga,[],mnt);

%%

topo_ivals = [-1000 -666; -666 -333; -333 0];
plot_scalpEvolution(epoq_ga,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));

