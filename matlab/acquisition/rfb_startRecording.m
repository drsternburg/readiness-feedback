
function rfb_startRecording(block_name)
% Executes a recording block

global opt BTB

bbci = rfb_bbci_setup;

id = logical(strcmp(opt.feedback.blocks,block_name));

pyff('startup'); pause(1)
pyff('init',opt.feedback.name); pause(5);
pyff('set',opt.feedback.pyff_params(id));

basename = sprintf('%s_%s_',opt.session_name,opt.feedback.blocks{id});
pyff('set','block_name',basename);
pyff('set','data_dir',BTB.Tp.Dir);

bbci_acquire_bv('close');
pyff('play','basename',basename,'impedances',0);
bbci_apply(bbci);

pyff('stop'); pause(1);
bvr_sendcommand('stoprecording');

fprintf('Finished\n')