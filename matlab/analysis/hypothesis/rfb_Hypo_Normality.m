
pval = zeros(Ns,2);
for ii = 1:Ns
    for jj = 1:2
        C = trial{ii}{jj}.cout(trial{ii}{jj}.valid);
        [~,pval(ii,jj)] = runstest(C);
        %[~,pval(ii,jj)] = lillietest(C);
        %[~,pval(ii,jj)] = kstest(zscore(C));
    end
end

%%
pval = zeros(Ns,1);
for ii = 1:Ns
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    %C1 = C1-mean(C1);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    %C2 = C2-mean(C2);
    [~,pval(ii)] = vartest2(C1,C2,'tail','left');
end

%%
T = 25;
t = -T:T;
scaling = 'coeff';

figure
for ii = 1:Ns
    
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    
    X1 = xcorr(C1,scaling,T);
    X2 = xcorr(C2,scaling,T);
    
    X1(T+1) = NaN;
    X2(T+1) = NaN;
    
    subplot(4,5,ii)
    hold on
    plot(t,X1)
    plot(t,X2)
    set(gca,'ylim',[0 1])
end

%%
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
        X2(:,kk) = xcorr(N,scaling,T);
    end
    X2 = mean(X2,2);
    
    %X1(T+1) = NaN;
    %X2(T+1) = NaN;
    
    subplot(4,5,ii)
    hold on
    plot(t,X1)
    plot(t,X2)
    set(gca,'ylim',[-.5 .5])
    grid on
end

%%
T = 25;
t = -T:T;
scaling = 'coeff';

X = zeros(length(t),Ns,2);
for ii = 1:Ns
    
    C1 = trial{ii}{1}.cout(trial{ii}{1}.valid);
    C2 = trial{ii}{2}.cout(trial{ii}{2}.valid);
    
    %%%
    n1 = length(C1);
    n2 = length(C2);
    n = min([n1 n2]);
    C1 = C1(1:n);
    C2 = C2(1:n);
    %%%
    
    X(:,ii,1) = xcorr(C1,scaling,T);
    X(:,ii,2) = xcorr(C2,scaling,T);
        
end

figure
plot(t,squeeze(mean(X,2)))









