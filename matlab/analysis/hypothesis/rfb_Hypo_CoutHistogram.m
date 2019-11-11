
variable = 't_ts2mo';

%%

% Nt = [100 300];
% Np = 25;
% Nb1 = Nt(1)/Np;
% Nb = sum(Nt)/Np;
% 
% C = zeros(Ns,Nb);
% for ii = 1:Ns
%     c = [trial{ii}{1}.(variable)(1:Nt(1));
%          trial{ii}{2}.(variable)(1:Nt(2))];
%     v = [trial{ii}{1}.valid(1:Nt(1));
%          trial{ii}{2}.valid(1:Nt(2))];
%     c(~v) = NaN;
%     c = (c-nanmean(c))/nanstd(c);
%     C(ii,:) = nanmean(reshape(c,Np,Nb));
% end
% 
% mu = nanmean(C);
% se = nanstd(C)/sqrt(Ns);
% 
% fig_init(25,10);
% hold on
% clrs = lines;
% H = bar(1:Nb1,mu(1:Nb1));
% H.FaceColor = clrs(1,:);
% errorbar(1:Nb1,mu(1:Nb1),se(1:Nb1),'k.')
% H = bar(Nb1+1:Nb,mu(Nb1+1:Nb));
% H.FaceColor = clrs(2,:);
% errorbar(Nb1+1:Nb,mu(Nb1+1:Nb),se(Nb1+1:Nb),'k.')
% set(gca,'xtick',1.5:1:Nb+1,'xticklabel',num2str((Np:Np:sum(Nt))'))
% set(gca,'xlim',[.25 Nb+.75],'box','on')

%%

Nt = [100 300];
Np = 25;
Nb1 = Nt(1)/Np;
Nb = sum(Nt)/Np;

C = zeros(sum(Nt),Ns);
for ii = 1:Ns
    c = [trial{ii}{1}.(variable)(1:Nt(1));
         trial{ii}{2}.(variable)(1:Nt(2))];
    v = [trial{ii}{1}.valid(1:Nt(1));
         trial{ii}{2}.valid(1:Nt(2))];
    c(~v) = NaN;
    C(:,ii) = (c-nanmean(c))/nanstd(c);
    %C(:,ii) = c;
end

C = reshape(C,Np,Nb,Ns);
C = permute(C,[1 3 2]);
C = reshape(C,Np*Ns,Nb);

mu = zeros(Nb,1);
ci = zeros(Nb,2);
for kk = 1:Nb
    [mu(kk),~,ci(kk,:)] = normfit(C(~isnan(C(:,kk)),kk));
end

ylim = [-1 1]*ceil(max(abs(ci(:)))*10)/10;

fig_init(25,10);
hold on
clrs = lines;

patch([0 4.5 4.5 0],[ylim(1) ylim(1) ylim(2) ylim(2)],clrs(1,:),...
    'FaceAlpha',.1,'linewidth',.01,'edgecolor',[1 1 1])
patch([4.5 16.75 16.75 4.5],[ylim(1) ylim(1) ylim(2) ylim(2)],clrs(2,:),...
    'FaceAlpha',.1,'linewidth',.01,'edgecolor',[1 1 1])
text(2.5,ylim(2)-.1,'Phase I: No feedback','HorizontalAlignment','center')
text(10.5,ylim(2)-.1,'Phase II: Feedback','HorizontalAlignment','center')

H = bar(1:Nb1,mu(1:Nb1));
H.FaceColor = clrs(1,:);
errorbar(1:Nb1,mu(1:Nb1),ci(1:Nb1,1)-mu(1:Nb1),ci(1:Nb1,2)-mu(1:Nb1),'k.')

H = bar(Nb1+1:Nb,mu(Nb1+1:Nb));
H.FaceColor = clrs(2,:);
errorbar(Nb1+1:Nb,mu(Nb1+1:Nb),ci(Nb1+1:Nb,1)-mu(Nb1+1:Nb),ci(Nb1+1:Nb,2)-mu(Nb1+1:Nb),'k.')

set(gca,'xtick',.5:1:Nb+1,'xticklabel',num2str((0:Np:sum(Nt))'))
set(gca,'xlim',[.25 Nb+.75],'box','on')

xlabel('Trial Nr')
ylabel('z-score')

%%
%print(gcf,'-dpng',[FIG_DIR sprintf('Hist25_%s',variable)])








