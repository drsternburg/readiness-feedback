%% Get TS -1000, for this is what is used to train the classifier
load /Users/vincentjonany/Desktop/Hypo.mat

%% 
trace1 = cell(Ns, 1);
trace2 = cell(Ns, 1);

for ii=1:Ns
    trace1{ii} = proc_selectClasses(epo{ii}, 'Idle Phase 1');
    trace1{ii} = proc_selectChannels(trace1{ii}, 'Acc*');
    trace2{ii} = proc_selectClasses(epo{ii}, 'Idle Phase 2');
    trace2{ii} = proc_selectChannels(trace2{ii}, 'Acc*');

end

%%

for i=1:Ns
    subplot(4,5, i);
    plot(var(squeeze(mean(trace2{i}.x,2))))
end