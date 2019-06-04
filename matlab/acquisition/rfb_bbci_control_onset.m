function packet = rfb_bbci_control_onset(cfy_out,timestamp,event,opt)

if cfy_out >= 0
    packet = {'i:emg',1, 's:timestamp', timestamp};
else
    packet = {'i:emg',0, 's:timestamp', timestamp};
end