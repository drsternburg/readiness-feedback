<<<<<<< HEAD:matlab/sup_bbci_control_emg.m
function packet = sup_bbci_control_emg(cfy_out,timestamp,event,opt)
=======

function packet = rfb_bbci_control_onset(cfy_out,event,opt)
>>>>>>> origin:matlab/rfb_bbci_control_onset.m

if cfy_out >= 0
    packet = {'i:emg',1, 's:timestamp', timestamp};
else
    packet = {'i:emg',0, 's:timestamp', timestamp};
end