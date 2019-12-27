%% Get all the trials in phase 2 from every subjects for segment [-450 -550]
% Based on Alpha
segment_ival = [-550 -450];
cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = size(cname, 2);
epoq = cell(Ns, Np);
rsqq = cell(Ns, Np);

for ii = 1:Ns
    % Get all the RP amps at Fz at -500ms then sort them
    epo_rp2 = proc_selectClasses(epo{ii}, 'RP Phase 2');
    alpha = trial{ii}{2}.alpha(trial{ii}{2}.valid);
    [~,si] = sort(alpha, 'ascend');
    Nc = length(alpha);
%     epo_rp2 = proc_selectIval(epo_rp2, segment_ival);
    epo_rp2.className = {'RP Phase 2'};
    epo_rp2.y = ones(1,Nc);    
    edges = [1 round(Nc/Np*(1:Np))];
    for jj = 1:Np
        epoq{ii,jj} = proc_selectEpochs(epo_rp2, si(edges(jj):edges(jj+1)));
        epoq{ii,jj}.className = cname(jj);
        rsqq{ii,jj} = proc_rSquareSigned(epoq{ii,jj},'Stats',1);
        epoq{ii,jj} = proc_average(epoq{ii,jj},'Stats',1);
    end
end

%% Get all the trials in phase 2 from every subjects for segment [-450 -550]
% based on RP amp
cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = size(cname, 2);
epoq = cell(Ns, Np);
rsqq = cell(Ns, Np);

time_interest = -500;
index_timeInterest = find(epo{1}.t == time_interest);
coll_rps = []
coll_couts = []

for ii = 1:Ns
    % Get all the RP amps at Fz at -500ms then sort them
    epo_rp2 = proc_selectClasses(epo{ii}, 'RP Phase 2');
    rp_amplitudes = squeeze(epo_rp2.x(index_timeInterest, 12, :));
    coll_rps = vertcat(coll_rps, rp_amplitudes);
    cout = trial{ii}{2}.cout(trial{ii}{2}.valid);
    coll_couts = vertcat(coll_couts, cout);
    [~,si] = sort(rp_amplitudes, 'descend');
    Nc = length(rp_amplitudes);
%     epo_rp2 = proc_selectIval(epo_rp2, segment_ival);
    epo_rp2.className = {'RP Phase 2'};
    epo_rp2.y = ones(1,Nc);    
    edges = [1 round(Nc/Np*(1:Np))];
    for jj = 1:Np
        epoq{ii,jj} = proc_selectEpochs(epo_rp2, si(edges(jj):edges(jj+1)));
        epoq{ii,jj}.className = cname(jj);
        rsqq{ii,jj} = proc_rSquareSigned(epoq{ii,jj},'Stats',1);
        epoq{ii,jj} = proc_average(epoq{ii,jj},'Stats',1);
    end
end
%%

T = array2table([normalize(coll_rps), coll_couts], 'VariableNames', {'RP', 'C'})
mdl = fitlm(T,'C ~ RP');
plotAdded(mdl);
disp(mdl);

%% Get all the trials in phase 2 from every subjects for segment [-450 -550]
% based on cout
segment_ival = [-550 -450];
cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = size(cname, 2);
epoq = cell(Ns, Np);
rsqq = cell(Ns, Np);


for ii = 1:Ns
    % Get all the RP amps at Fz at -500ms then sort them
    epo_rp2 = proc_selectClasses(epo{ii}, 'RP Phase 1');
%     rp_amplitudes = squeeze(epo_rp2.x(index_timeInterest, 11, :));
    cout = trial{ii}{1}.cout(trial{ii}{1}.valid);
    [~,si] = sort(cout, 'descend');
    Nc = length(cout);
%     epo_rp2 = proc_selectIval(epo_rp2, segment_ival);
    epo_rp2.className = {'RP Phase 1'};
    epo_rp2.y = ones(1,Nc);    
    edges = [1 round(Nc/Np*(1:Np))];
    for jj = 1:Np
        epoq{ii,jj} = proc_selectEpochs(epo_rp2, si(edges(jj):edges(jj+1)));
        epoq{ii,jj}.className = cname(jj);
        rsqq{ii,jj} = proc_rSquareSigned(epoq{ii,jj},'Stats',1);
        epoq{ii,jj} = proc_average(epoq{ii,jj},'Stats',1);
    end
end


%% Do some averaging for the quarters
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

%%
clab_grid = {'F3-4','FC5-6','C5-6','CP5-6','P3-4'};
mnt2 = mnt_restrictMontage(mnt,clab_grid);
rfb_gridplot(epoq_ga,[],mnt2);

%%
% topo_ivals = [-550 -525; -525 -500; -500 -475; -475 -450];
topo_ivals = [-900 -600; -600 -300; -300 0];

%     subplot(2, 4, ii);
plot_scalpEvolution(rsqq_ga,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));

