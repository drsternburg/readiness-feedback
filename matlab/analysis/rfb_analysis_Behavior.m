
subj_code = 'VPfbz';

flag.premature = 0;
flag.duration_outlier = 1;
flag.cout_outlier = 1;
flag.eeg_artifact = 1;
flag.bad_online_onset = 1;

var_names = {'Classifier output (a.u.)',...
             'Waiting time (sec)',...
             'Movement duration (ms)'};

%% prepare dataset
[trial,mrk,cnt,mnt] = rfb_getData(subj_code,flag);

%% compare phases
X = cell(3,2);
X{1,1} = trial{1}.cout(trial{1}.valid);
X{2,1} = trial{1}.t_ts2mo(trial{1}.valid)/1000;
X{3,1} = trial{1}.t_mo2pp(trial{1}.valid);
X{1,2} = trial{2}.cout(trial{2}.valid);
X{2,2} = trial{2}.t_ts2mo(trial{2}.valid)/1000;
X{3,2} = trial{2}.t_mo2pp(trial{2}.valid);

pval = zeros(3,1);
for jj = 1:3
    pval(jj) = ranksum(X{jj,1},X{jj,2});
end

fig_init(30,30);
clrs = lines;

for jj = 1:3
    
    x1 = X{jj,1};
    m1 = mean(x1);
    x2 = X{jj,2};
    m2 = mean(x2);
    
    subplot(3,4,(1:3)+(jj-1)*4)
    hold on
    bar(1:length(x1),x1,'FaceColor',clrs(1,:))
    bar(length(x1)+1:length(x1)+length(x2),x2,'FaceColor',clrs(2,:))
    ylim1 = get(gca,'ylim');
    ylabel(var_names{jj})
    if jj==3
        xlabel('Trial')
    end
    
    subplot(3,4,4+(jj-1)*4)
    histogram(x1,'Normalization','pdf')
    hold on
    histogram(x2,'Normalization','pdf')
    ylim2 = get(gca,'ylim');
    xlim2 = get(gca,'xlim');
    plot([m1 m1],ylim2,'color',clrs(1,:),'linewidth',2)
    plot([m2 m2],ylim2,'color',clrs(2,:),'linewidth',2)
    text(diff(xlim2)*.05+xlim2(1),diff(ylim2)*.33+ylim2(1),sprintf('p=%0.6f',pval(jj)))
    set(gca,'xlim',ylim1,'ylim',ylim2)
    set(gca,'ytick',[])
    set(gca,'XDir','reverse')
    camroll(-90)
    
end
















