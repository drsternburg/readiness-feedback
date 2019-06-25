
function L = rfb_getPyffLog(subj_code,phase_name)

global BTB opt

ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;

logfilename = sprintf('%s%s/%s_%s_',BTB.RawDir,ds_name,opt.session_name,phase_name);

fid = fopen(logfilename);

if fid==-1
    error('File %s not found.',logfilename)
end

D = textscan(fid,'[%f sec] %s %s %f %f %s %s %s %f','delimiter','|','CollectOutput',1);

Nt = length(D{1});

L.time = D{1};
L.block_nr = zeros(Nt,1);
L.trial_nr = zeros(Nt,1);
for ii = 1:Nt
    d = textscan(D{2}{ii,1},'Block: %d');
    L.block_nr(ii) = d{1};
    d = textscan(D{2}{ii,2},'Trial: %d');
    L.trial_nr(ii) = d{1};
end
L.cout = D{3}(:,1);
L.feedback = D{3}(:,2);
L.t_mo2pp = D{5};


