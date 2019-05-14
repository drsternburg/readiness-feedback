function packet = sup_bbci_control_emg(cfy_out,event,opt)

if cfy_out >= 0
    packet = {'i:emg',1};
else
    packet = {'i:emg',0};
end