
function [mrk,cnt,mnt] = tl_proc_loadData(subj_code,phase_name)

if nargin<2
    [mrk1,cnt1,mnt] = tl_proc_loadData(subj_code,'Phase1');
    [mrk2,cnt2] = tl_proc_loadData(subj_code,'Phase2');
    [mrk3,cnt3] = tl_proc_loadData(subj_code,'RT');
    fprintf('Concatenating phases...\n')
    if not(isempty(mrk3))
        [cnt,mrk] = proc_appendCnt({cnt1,cnt2,cnt3},{mrk1,mrk2,mrk3});
    else
        [cnt,mrk] = proc_appendCnt(cnt1,cnt2,mrk1,mrk2);
    end
    return
end

global BTB

ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
session_name = 'TrafficLight';

filename_eeg = sprintf('%s/%s_%s_%s',ds_name,session_name,phase_name,subj_code);
filename_mrk = sprintf('%s%s_mrk.mat',BTB.MatDir,filename_eeg);

if not(exist([BTB.MatDir filename_eeg '.mat'],'file')) % because for one or two participants we didn't record RT data
    mrk = [];
    cnt = [];
    mnt = [];
    return
end

fprintf('Loading data set %s, %s...\n',ds_name,phase_name)

if nargout>1 || not(exist(filename_mrk,'file'))
    [cnt,mrk,mnt] = file_loadMatlab(filename_eeg);
    mnt.scale_box = [];
%     mnt = mnt_scalpToGrid(mnt);
end
if exist(filename_mrk,'file')
    load(filename_mrk)
end

ci = logical(strcmp(mrk.className,'start silent'));
if any(ci)
    mrk.className{ci} = 'start phase1';
end
