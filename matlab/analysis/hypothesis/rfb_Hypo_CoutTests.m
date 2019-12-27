%% Initial
couts = cell(2);
for ii = 1:Ns
    for jj= 1:2
        couts{jj} = vertcat(couts{jj}, trial{ii}{jj}.cout(trial{ii}{jj}.valid));
    end
end


% group = [    ones(size(couts{1}));
%          2 * ones(size(couts{2}))];
%      
% figure
% boxplot([couts{1}; couts{2}],group,'whisker', 4);
% set(gca,'XTickLabel',{'Phase I','Phase II'})

figure 
l1 = histogram(couts{1},'Normalization','pdf')
hold on
l2 = histogram(couts{2},'Normalization','pdf')
xline(mean(couts{1}), 'Color', 'b', 'LineWidth', 1.3)
xline(mean(couts{2}), 'Color', 'r', 'LineWidth', 1.3)
[h, p] = ttest2(couts{1}, couts{2});
xlabel("Classifier output")
ylabel("Density")
title('Distribution of classifier outputs between two phases (p = 0.001)')
legend([l1,l2],{'Phase I' , 'Phase II'});


%% test for randomness
pval = zeros(Ns,2);
for ii = 1:Ns
    for jj = 1:2
        C = trial{ii}{jj}.cout(trial{ii}{jj}.valid);
        [~,pval(ii,jj), stat] = runstest(C);
    end
end
disp(pval<.05)

%% test for normality
pval1 = zeros(Ns,2);
pval2 = zeros(Ns,2);
for ii = 1:Ns
    for jj = 1:2
        C = trial{ii}{jj}.cout(trial{ii}{jj}.valid);
        [~,pval1(ii,jj)] = lillietest(C);
        [~,pval2(ii,jj)] = kstest(zscore(C));
    end
end
disp(pval1<.05)
disp(pval2<.05)

%% test for difference in variances
pval = zeros(Ns,1);
for ii = 1:Ns
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    [~,pval(ii)] = vartest2(C1,C2);
end
disp(pval<.05)

%% check cross-correlations
T = 25;
t = -T:T;
scaling = 'coef';

figure
for ii = 1:Ns
    
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    
    X1 = xcorr(C1,scaling,T);
    X2 = xcorr(C2,scaling,T);
        
    subplot(4,5,ii)
    hold on
    p1 = plot(t,X1);
    p2 = plot(t,X2);
    title(subjs_all{ii});
    set(gca,'xlim',[0 T])
    set(gca,'ylim',[0 1])
    xlabel('Lags (trial)');
    ylabel('Corr');
    grid on
end
hLegend = legend([p1, p2], {'Phase I', 'Phase II'});

%% compare cross-correlation against randomly permuted samples
T = 25;
t = -T:T;
scaling = 'coeff';
nrep = 100;

figure
for ii = 1:Ns
    
    C = trial{ii}{1}.cout(trial{ii}{1}.valid);
    X1 = xcorr(C,scaling,T);
    
    X2 = zeros(size(X1,1),nrep);
    for kk = 1:nrep
        N = C(randperm(length(C)));
        %N = random_phase_surrogate(C);
        X2(:,kk) = xcorr(N,scaling,T);
    end
    X2 = mean(X2,2);
    
    X1(T+1) = NaN;
    X2(T+1) = NaN;
    
    subplot(4,5,ii)
    hold on
    plot(t,X1)
    plot(t,X2)
    set(gca,'ylim',[0 1])
    grid on
end









