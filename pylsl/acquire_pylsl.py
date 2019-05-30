from pylsl import StreamInlet, resolve_stream
import numpy as np 
import time

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')
info = streams[0]

# create a new inlet to read from the stream
inlet = StreamInlet(info)

print('Connected to outlet ' + info.name() + '@' + info.hostname())
start_time = time.time()
cnt = np.zeros(32)

while(time.time() - start_time < 1.0):
    sample, timestamp = inlet.do_pull_sample()
    np.vstack((cnt, sample))
    # time.sleep(1)
print(cnt.shape)
# This should have 5000 data points!