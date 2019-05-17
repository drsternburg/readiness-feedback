% setenv('PYTHONPATH', '/anaconda2/lib/python2.7/site-packages')
% startup_bbci_toolbox('DataDir', '/Users/vincentjonany/demo_data/demoMat/', 'TmpDir', '/Users/vincentjonany/demo_data')
% BTB.Acq.IoAddr = 8888;
set_data = {'rp_dist_init', cout};
pyff('startup'); pause(10);
pyff_sendUdp('interaction-signal', 's:_feedback', 'ReadinessFeedback','command','sendinit'); pause(5);
pyff_sendUdp('interaction-signal', set_data); pause(5);
pyff_sendUdp('interaction-signal', 'command', 'play'); 
