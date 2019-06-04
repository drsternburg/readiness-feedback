
function packet = rfb_bbci_control_cout(cfy_out,timestamp, event,opt)

packet = {'i:cl_output', cfy_out, 's:timestamp', timestamp};