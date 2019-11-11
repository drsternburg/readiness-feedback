
%%
cname = {'RP Q1','RP Q2','RP Q3','RP Q4'};
Np = 4;
epoq = cell(Ns,Np);
rsqq = cell(Ns,Np);
for ii = 1:Ns
    
    cout = trial{ii}{1}.cout(trial{ii}{1}.valid);
    Nc = length(cout);
    
    epo12 = proc_selectClasses(epo{ii},'RP Phase 1');
    epo12.className = {'RP'};
    
%     cout = [trial{ii}{1}.cout(trial{ii}{1}.valid);...
%             trial{ii}{2}.cout(trial{ii}{2}.valid)];
%     [~,si] = sort(cout);
%     Nc = length(cout);
%     epo1 = proc_selectClasses(epo{ii},'RP Phase 1');
%     epo2 = proc_selectClasses(epo{ii},'RP Phase 2');
%     epo12 = proc_appendEpochs(epo1,epo2);
%     epo12.className = {'RP'};
%     epo12.y = ones(1,Nc);
    
    edges = [1 round(Nc/Np*(1:Np))];
    for jj = 1:Np
        epoq{ii,jj} = proc_selectEpochs(epo12,edges(jj):edges(jj+1));
        epoq{ii,jj}.className = cname(jj);
        rsqq{ii,jj} = proc_rSquareSigned(epoq{ii,jj},'Stats',1);
        %epoq{ii,jj} = proc_average(epoq{ii,jj});
        epoq{ii,jj} = proc_average(epoq{ii,jj},'Stats',1);
    end
end

%%
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

%print(gcf,'-dpng',[FIG_DIR 'CoutValidity_QuartileERPs'])

%%
topo_ivals = [-1000 -666; -666 -333; -333 0];
alph = .001;
rsqq_ga_ = rsqq_ga;
rsqq_ga_.x(rsqq_ga_.p>alph) = 0;
fig_init(20,20);
H = plot_scalpEvolution(rsqq_ga_,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));
H.cb(1).delete
H.cb(2).delete
H.cb(3).delete
set(H.cb(4),'pos',[.88 .36 .039 .24])

%%
topo_ivals = [-1000 -666; -666 -333; -333 0];
%topo_ivals = [-1000 -759; -750 -500; -500 -250; -250 0];
alph = .001;
epoq_ga_ = epoq_ga;
epoq_ga_.x(rsqq_ga.p>alph) = 0;
fig_init(20,20);
H = plot_scalpEvolution(epoq_ga_,mnt,topo_ivals,defopt_scalp_r('ExtrapolateToZero',1,'ContourPolicy','withinrange'));
H.cb(1).delete
H.cb(2).delete
H.cb(3).delete
set(H.cb(4),'pos',[.88 .36 .039 .24])

print(gcf,'-dpng',[FIG_DIR 'CoutValidity_QuartileOnsets'])

%%
class = {'RP Phase 1','RP Phase 2'};
A = [];
C = [];
S = [];
P = [];
for ii = 1:Ns
    A_ = [];
    C_ = [];
    for jj = 1:2
        valid = trial{ii}{jj}.valid;
        epo_ = proc_selectClasses(epo{ii},class{jj});
        amp = proc_meanAcrossTime(epo_,[-100 0]);
        A_ = cat(1,A_,squeeze(amp.x(:,util_chanind(epo_,'Cz'),:)));
        C_ = cat(1,C_,trial{ii}{jj}.cout(valid));
        P = cat(1,P,ones(sum(valid),1)*(jj-1));
    end
    A = cat(1,A,A_);
    C_ = zscore(C_);
    C = cat(1,C,C_);
    S = cat(1,S,ones(length(C_),1)*ii);
end

T = array2table([S C A P]);
T.Properties.VariableNames = {'Subj','Cout','Amp','Phase'};

%%
M = fitlme(T,'Amp ~ 1 + Cout + Cout:Phase + (1 + Cout | Subj)');
disp(M)

%%
M = fitlme(T,'Amp ~ 1 + Cout + (1 + Cout | Subj)');
disp(M)

%%
fig_init(15,15);
clrs = lines;
hold on
scatter(T.Cout,T.Amp,'.')
P = predict(M);
for ii = 1:Ns
    plot(T.Cout(T.Subj==ii),P(T.Subj==ii),'color',clrs(2,:))
end
P = predict(M,'conditional',0);
plot(T.Cout,P,'color',clrs(4,:),'linewidth',2)
xlabel('C_{out} (z-score)')
ylabel('RP amplitude (\muV)')
set(gca,'ylim',[-60 60])
grid on

print(gcf,'-dpng',[FIG_DIR 'CoutValidity_AmplitudeModel'])

%%
fig_init(15,15);
clrs = lines;
hold on
T2 = table();
T2.Cout = linspace(-4,4,1000)';
T2.Subj = ones(1000,1)*2;
[mu,ci] = predict(M,T2,'conditional',0);
H = patch([T2.Cout;flipud(T2.Cout)],[ci(:,1);flipud(ci(:,2))],clrs(1,:),'edgecolor',[1 1 1],'facealpha',.1,'linewidth',.1);
plot(T2.Cout,mu,'color',clrs(1,:),'linewidth',2)
xlabel('C_{out} (z-score)')
ylabel('RP amplitude (\muV)')
axis square
grid on
























