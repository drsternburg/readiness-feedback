
function [cnt,mrk,mnt] = rfb_convertBVData(subj_code,phase_name)

global opt BTB

ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = fullfile(ds_name,sprintf('%s_%s_%s',opt.session_name,phase_name,subj_code));

% define channels
hdr = file_readBVheader(filename);
if isfield(hdr,'impedances')
    noninfclab = ['not' hdr.clab(isinf(hdr.impedances))];
else
    noninfclab = '*';
end

% read raw data
[cnt,mrk] = file_readBV(filename,'fs',opt.acq.fs,'filt',opt.acq.filt,'clab',noninfclab);

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
file_saveMatlab(filename,cnt,mrk,mnt);
fprintf('\nFile %s successfully converted and saved.\n',filename)