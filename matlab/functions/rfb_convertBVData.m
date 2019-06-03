
function [cnt,mrk,mnt] = rfb_convertBVData(file)

global opt

% define channels
hdr = file_readBVheader(file);
if isfield(hdr,'impendances')
    noninfclab = ['not' hdr.clab(isinf(hdr.impedances))];
else
    noninfclab = '*';
end

% read raw data
[cnt,mrk] = file_readBV(file,'fs',opt.acq.fs,'filt',opt.acq.filt,'clab',noninfclab);

% define markers
mrk = mrk_defineClasses(mrk,opt.mrk.def);
mrk = rmfield(mrk,'event');

% set montage
mnt = mnt_setElectrodePositions(cnt.clab);
mnt.scale_box = [];
mnt = mnt_scalpToGrid(mnt);

% perform CAR
rrclab = util_scalpChannels(cnt);
cnt = proc_commonAverageReference(cnt,rrclab,rrclab);

% save
file_saveMatlab(file,cnt,mrk,mnt);
fprintf('\nFile %s successfully converted and saved.\n',file)