
function formula_fit = mixedModelSelection(T,resp_var)

subj_var = 'Subj';
expl_var = setxor({resp_var,subj_var},T.Properties.VariableNames);
Ne = length(expl_var);

%%
interact  = [];
kk = 1;
for ii = 1:Ne
    for jj = ii+1:Ne
        interact{kk} = sprintf('%s:%s',expl_var{ii},expl_var{jj});
        kk = kk+1;
    end
end
Ni = length(interact);

%%
formula_fixed = sprintf('%s~1%s%s',resp_var,catterms(expl_var,'+'),...
                                            catterms(interact,'+'));

%%
ind = zeros(Ne,1);
for ii = 1:Ne
    formula_base = sprintf('%s + (1|%s)',formula_fixed,subj_var);
    formula_test = sprintf('%s + (1+%s|%s)',formula_fixed,expl_var{ii},subj_var);
    fprintf('Testing random effects: %s... ',expl_var{ii})
    lme_base = fitlme(T,formula_base,'FitMethod','REML');
    lme_test = fitlme(T,formula_test,'FitMethod','REML');
    table = compare(lme_base,lme_test);
    fprintf('%0.6f\n',table.pValue(2))
    if table.pValue(2)<.05
        ind(ii) = 1;
    end
end
ind = find(ind);

%%
formula_rand = '+(1';
for ii = 1:length(ind)
    formula_rand = sprintf('%s+%s',formula_rand,expl_var{ind(ii)});
end
formula_rand = sprintf('%s|%s)',formula_rand,subj_var);

%%
ind = zeros(Ni,1);
for ii = 1:Ni
    formula_base = sprintf('%s~1%s%s%s',resp_var,...
                                      catterms(expl_var,'+'),...
                                      catterms(interact,'+'),...
                                      formula_rand);
    formula_test = sprintf('%s~1%s%s%s',resp_var,...
                                      catterms(expl_var,'+'),...
                                      catterms(interact(setdiff(1:Ni,ii)),'+'),...
                                      formula_rand);
    fprintf('Testing fixed effects: interaction %s... ',interact{ii})
    lme_base = fitlme(T,formula_base,'FitMethod','ML');
    lme_test = fitlme(T,formula_test,'FitMethod','ML');
    %table = compare(lme_test,lme_base,'NSim',100);
    table = compare(lme_test,lme_base);
    fprintf('%0.6f\n',table.pValue(2))
    if table.pValue<.05
        ind(ii) = 1;
    end
end
ind = find(ind);

%%
formula_interact = catterms(interact(ind),'+');

%%
ind = zeros(Ne,1);
for ii = 1:Ne
    formula_base = sprintf('%s~1%s%s%s',resp_var,...
                                      catterms(expl_var,'+'),...
                                      formula_interact,...
                                      formula_rand);
    formula_test = sprintf('%s~1%s%s%s',resp_var,...
                                      catterms(expl_var(setdiff(1:Ne,ii)),'+'),...
                                      formula_interact,...
                                      formula_rand);
    fprintf('Testing fixed effects: main effect %s... ',expl_var{ii})
    lme_base = fitlme(T,formula_base,'FitMethod','ML');
    lme_test = fitlme(T,formula_test,'FitMethod','ML');
    table = compare(lme_test,lme_base);
    %table = compare(lme_test,lme_base,'NSim',100);
    fprintf('%0.6f\n',table.pValue(2))
    if table.pValue<.05
        ind(ii) = 1;
    end
end
ind = find(ind);

%%
formula_fixed = catterms(expl_var(ind),'+');

%%
formula_fit = sprintf('%s~1%s%s%s',resp_var,...
                                    formula_fixed,...
                                    formula_interact,...
                                    formula_rand);










%%
function s = catterms(terms,link)
N = length(terms);
s = [];
for ii = 1:N
    s = sprintf('%s%s%s',s,link,terms{ii});
end

