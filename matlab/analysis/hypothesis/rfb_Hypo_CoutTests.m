
%% test for randomness
pval = zeros(Ns,2);
for ii = 1:Ns
    for jj = 1:2
        C = trial{ii}{jj}.cout(trial{ii}{jj}.valid);
        [~,pval(ii,jj)] = runstest(C);
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
scaling = 'coeff';

figure
for ii = 1:Ns
    
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    
    X1 = xcorr(C1,scaling,T);
    X2 = xcorr(C2,scaling,T);
        
    subplot(4,5,ii)
    hold on
    plot(t,X1)
    plot(t,X2)
    set(gca,'ylim',[0 1],'xlim',[-T T])
    grid on
end

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









