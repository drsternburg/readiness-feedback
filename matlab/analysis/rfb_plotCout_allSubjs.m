
flag.bad_online_onset = 0;
flag.duration_outlier = 0;
flag.cout_outlier = 0;
flag.premature = 0;
flag.eeg_artifact = 0;

Ns2 = length(subjs_all);

fig_init(30,20);
clrs = lines;

for ii = 1:Ns2
    
    trial = rfb_getData(subjs_all{ii},flag);
%     c1 = trial{1}.cout(1:Nt(1));
%     c2 = trial{2}.cout(1:Nt(2));
%     v1 = trial{1}.valid(1:Nt(1));
%     v2 = trial{2}.valid(1:Nt(2));
    c1 = trial{1}.cout;
    c2 = trial{2}.cout;
    v1 = trial{1}.valid;
    v2 = trial{2}.valid;
    c1(~v1) = NaN;
    c2(~v2) = NaN;
    
    subplot(4,7,ii)
    hold on
    plot(1:length(c1),c1,'color',clrs(1,:))
    plot(length(c1)+1:length(c1)+length(c2),c2,'color',clrs(2,:))
    if not(ismember(subjs_all{ii},subjs_excl))
        title(subjs_all{ii})
    else
        title(subjs_all{ii},'fontweight','normal')
    end
    
end

%print(gcf,'-dpng',[FIG_DIR 'Cout_ALL'])
