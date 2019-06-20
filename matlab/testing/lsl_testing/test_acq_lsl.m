%%
clab = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10'
};

bbci.signal.clab = clab;

bbci.source.acquire_param = {'fs', 1000, 'clab', clab, 'blocksize',10};
state = bbci_acquire_lsl('init');
state.inlet.x.set_postprocessing(4);
cnt = [];
tmx = [];
i = 1;
tic
while(size(tmx,2)< 5000)
    [cntx, tm] = state.inlet.x.pull_sample();
    cnt = [cnt cntx];
    tmx = [tmx tm];
    if (rem(i,50)==0) % this is 100hz
        diff_tmx = tmx(i) - tmx(i-50 + 1);
%         disp(diff_tmx);
%         toc
    end
    i = i + 1;
end
toc
hist(diff(tmx))

%% pull chunk test

clab = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10'
};

bbci.signal.clab = clab;

bbci.source.acquire_param = {'fs', 1000, 'clab', clab, 'blocksize',10};
state = bbci_acquire_lsl('init');
state.inlet.x.set_postprocessing(4);
cnt = [];
tmx = [];
i = 1;
tic
while(toc < 100)
    [chunk, tm] = state.inlet.x.pull_chunk();
    tmx = [tmx tm(1, :)];
    disp(size(chunk));
    pause(1) % this is when I can control it to make it pause for 0.1, then I can get the data in 100hz
end
toc
hist(diff(tmx))


%% Test BBCI_ACQIORE_BV
state = bbci_acquire_bv('init', state);                   
tic
datas = [];
tmx = [];
i = 0;
while(size(data,1) < 10000)
    [data, markertime, markerdescr, state] = bbci_acquire_bv(state); 
    i = i+ size(data,1);
    
%     if(isempty(data))
%         disp('empty array');
%     end
    datas = vertcat(datas, data);
end
toc
bbci_acquire_bv('close')