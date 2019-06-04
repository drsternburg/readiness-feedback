
function D = rfb_getLogData(subj_code)

global BTB

ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;

logfilename = sprintf('%s%s/bbci_apply_log_phase2.txt',BTB.RawDir,ds_name);

fid = fopen(logfilename);

D = textscan(fid,'%fs %s [%f] {%s','delimiter','|','CollectOutput',1);