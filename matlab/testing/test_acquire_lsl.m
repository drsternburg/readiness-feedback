% 
% state = bbci_acquire_lsl('init');
% T = 30000;
% t = zeros(T,1);
% d = zeros(T,32);
% for ii = 1:T
%     tic
%     [d(ii,:),mrktime,mrkdesc,state] = bbci_acquire_lsl(state);
%     t(ii) = toc;
%     %pause(.001)
% end
% 
% %%
% T = 30000;
% ts = zeros(T,1);
% t = zeros(T,1);
% d = zeros(T,32);
% timeout=60;
% for ii = 1:T
%     tic
%     [d(ii,:),ts(ii)] = state.inlet.x.pull_sample(timeout);
%     ts(ii)
%     t(ii) = toc;
% end

%% PULLING CHUNKS
state = bbci_acquire_lsl('init');

clab_amp1 = {'Fp1', 'Fp2', 'F3', 'F4', 'C3',...
    'C4', 'P3', 'P4', 'O1', 'O2', 'F7', 'F8', ...
    'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'Oz',...
    'FC1', 'FC2', 'CP1', 'CP2', 'FC5', 'FC6', 'CP5',...
    'CP6', 'TP9', 'TP10', 'EOGv', 'EOGl'};
state.clab = clab_amp1;
state.nChans = 32;
tic 
data = [];
timestamps = [];
sizes = [];

while(toc < 1)
   [d,ts] = state.inlet.x.pull_chunk();
   data=[data, d];
   timestamps=[timestamps, ts];
   sizes = [sizes, size(d)];
end

state.inlet.x.delete(); 
state.inlet.mrk.delete();



