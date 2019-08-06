# ReadinessFeedback.py -
# MSK, 2019
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#
#

import pygame, os
from FeedbackBase.PygameFeedback import PygameFeedback
from __builtin__ import str
from collections import deque
import numpy as np
import scipy.stats as stats
import math
import threading
import time
import datetime

class ReadinessFeedback(PygameFeedback):
    
    def init(self):
        PygameFeedback.init(self)

        ########################################################################
        
        self.screenPos = [1280, 0]
        # self.screenPos = [1920, 0]
        self.screenSize = [1280, 1024]
        #self.screenPos = [0, 0]
        #self.screenSize = [1000, 1000]
        self.screen_center = [self.screenSize[0] / 2, self.screenSize[1] / 2]
        self.caption = "ReadinessFeedback"

        self.background_color = [127, 127, 127]
        self.text_fontsize = 75
        self.text_color = [64, 64, 64]
        self.char_fontsize = 100
        self.char_color = [0, 0, 0]
        self.white_color = [255,255,255]
        self.red_color = [225, 0, 0]
        self.radius = 25
        self.cross_length = 25
 
        self.pause_text = 'Paused. Press pedal to start...'
        self.end_text = 'Finished. Session has ended...'
        self.paused = True
        self.on_trial = False
        self.searching_rp = False
        
        self.block_counter = 1
        self.trial_counter = 0

        ########################################################################

        self.marker_identifier = {
            10:"Trial starts: " + str(self.trial_counter),
            11:"Trial ends" ,
            20:"block starts: " + str(self.block_counter),
            21:"block ends",
            30:"feedback",
            255:"quit condition reached"
        }

        self.marker_trial_start = 10
        self.marker_trial_end = 11
        self.marker_block_start = 20
        self.marker_block_end = 21
        self.marker_rp_shown = 30
        self.marker_quit_condition = 255

        ########################################################################
        # MAIN PARAMETERS TO BE SET IN MATLAB

        self.listen_to_keyboard = 0
        self.show_feedback = False
        self.end_after_x_bps = 10
        self.pause_every_x_bps = 5
        self.data_dir = '/tmp'
        self.block_name = 'session_tmp'
        self.phase1_cout = []

        ########################################################################

        # logic parameters
        self.emg_history = []
        self.eeg_history = []
        self.last_cross_shown = pygame.time.get_ticks()
        self.last_circle_shown = pygame.time.get_ticks()
        self.last_pedal_pressed = pygame.time.get_ticks()
        self.one_std_val = 15
        self.mean_value = 50
        
    def pre_mainloop(self):
        PygameFeedback.pre_mainloop(self)
        self.font_text = pygame.font.Font(None, self.text_fontsize)
        self.font_char = pygame.font.Font(None, self.char_fontsize)
        self.reset_trial_states()
        self.on_pause()
        self.set_dist_training_data()
        self.render_text(self.pause_text)
    
    def set_dist_training_data(self):
        self.rp_dist_init = sorted(self.phase1_cout)
        self.mu = np.average(self.rp_dist_init)
        self.std = np.std(self.rp_dist_init)
    
    def reset_trial_states(self):
        self.already_interrupted = False
        self.already_interrupted_silent = False
        self.this_prompt = False

    def post_mainloop(self):
        PygameFeedback.post_mainloop(self)

    def on_pause(self):
        self.log('Paused. Waiting for participant to continue...')
        self.paused = True
        self.on_trial = False
        self.draw_text(self.pause_text)
    
    def end_session(self):
        self.log('Phase ends')
        self.show_feedback = False
        self.trial_counter = 0
        self.block_counter = 1
        self.reset_trial_states()       
        self.paused = True
        self.on_trial = False
        self.send_parallel_log(self.marker_quit_condition) #quit condition
        self.draw_text(self.end_text)

    def unpause(self):
        self.send_parallel_log(self.marker_block_start) #Block starts here
        # Restart the history
        self.eeg_history = []
        self.emg_history = []
        self.paused = False
        self.on_trial = True
        self.present_stimulus()

    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()

    def on_control_event(self, data):  
        if self.on_trial and not self.paused and self.show_feedback and not self.searching_rp:
            now = datetime.datetime.utcnow().strftime('%H:%M:%S.%f')[:-3]
            if u'emg' in data:
                self.emg_history.append({
                    'data': data[u'emg'],
                    'matlab_timestamp': data[u'timestamp'],
                    'pyff_timestamp': now
                })
            if u'cl_output' in data:
                self.eeg_history.append({
                    'data': data[u'cl_output'],
                    'matlab_timestamp': data[u'timestamp'],
                    'pyff_timestamp': now
                })
                
        if u'pedal' in data and data[u'pedal'] == 1.0:
            self.pedal_press()
            
    def transform_rp(self, rp):
        z_score = (rp - self.mu) / self.std
        return int(round(self.one_std_val * z_score + self.mean_value))

    def write_to_file(self, content):
        f = open(self.data_dir + '/' + self.block_name, "a")
        f.write(content)
        f.write("\n")
        f.close()

    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            self.keypressed = False
            if self.on_trial and not self.this_prompt:
                self.pedal_press()
                return
            if self.paused and not self.on_trial:
                self.unpause()
                return
            if not self.on_trial:
                self.already_interrupted = False
                return
        
    def pedal_press(self):
        now = pygame.time.get_ticks()
        self.log('pedal press: trial ' + str(self.trial_counter))
        if self.paused:
            self.unpause()
        elif (now - self.last_pedal_pressed < 3700):
            pass
            # Trailing button press
            # Do nothing?
        else:
            # restart the trial if they press it for less than 2 seconds
            if(now - self.last_circle_shown < 1000):
                self.log("Participant needs to wait 1 seconds.")
                self.draw_text("Too quick, retry again")
                pygame.time.delay(1000) #delay for 1 second      
                
            else: 
                threading.Thread(target = self.draw_circle, args=[self.red_color]).start() #presents red circle
                pygame.time.delay(1000) #delay for 1 second    
                
                self.trial_counter +=1

                if self.show_feedback:
                    # Calculating the RP based on EEG and EMG history
                    index_emg_onset, pedal_timestamp_str, press_onset_diff= self.check_emg_onset()
                    if index_emg_onset == -1: # meaning there is an error in the EMG onset
                        self.trial_counter -=1 #doesn't count as a trial
                        self.log("Movement too quick/slow, trial doesn't count")
                        self.draw_text("Movemnt too quick/slow")
                        pygame.time.delay(1000) #delay for 1 second  
                    else:
                        rp = self.eeg_history[index_emg_onset]['data']
                        # rp = np.random.uniform(np.min(self.rp_dist_init), np.max(self.rp_dist_init), 1)[0]
                        rp_val_transformed = self.transform_rp(rp)

                        # write to file, the necessary info about the rp
                        content_to_write = self.log(
                            "Block: " + str(self.block_counter) +  
                            " | Trial: " + str(self.trial_counter) +
                            " | " + str(rp) + 
                            " | " + str(rp_val_transformed) + 
                            " | " + self.eeg_history[index_emg_onset]['pyff_timestamp'][-12:] + 
                            " | " + pedal_timestamp_str +
                            " | " + self.eeg_history[index_emg_onset]['matlab_timestamp'] + 
                            " | " + str(press_onset_diff))

                        self.write_to_file(content_to_write)
                        # Present the RP value on screen
                        self.send_parallel_log(self.marker_rp_shown) #Sends the marker that the rp is being shown now.
                        self.draw_text(str(rp_val_transformed)) 
                        pygame.time.delay(1500) #delay for 1.5 seconds
                
                if self.trial_counter == self.end_after_x_bps :
                    self.send_parallel_log(self.marker_trial_end) #Trial ends here
                    pygame.time.delay(10) # Pause for 10 ms to let the marker be sent
                    self.send_parallel_log(self.marker_block_end) #Block ends here
                    self.end_session()
                    return

                # Give the user a pause/break when it has reached the maximum block during that session.
                # Or to give the user time to think the next strategy 
                if self.trial_counter > 0 and self.trial_counter % self.pause_every_x_bps == 0:
                    self.send_parallel_log(self.marker_trial_end) #Trial ends here
                    pygame.time.delay(10) # Pause for 10 ms to let the marker be sent
                    self.send_parallel_log(self.marker_block_end) #Block ends here
                    self.block_counter += 1
                    self.reset_trial_states()
                    self.on_pause()
                    return
            
            # sends a parallel log to show that the trial ends. 
            self.send_parallel_log(self.marker_trial_end) #Trial ends here
            self.present_stimulus()
            # Restart the history
            self.last_pedal_pressed = now
            self.eeg_history = []
            self.emg_history = []
        
    # Returns the index in the eeg/emg history array when it finds the emg onset. And -1 if it there is an error.
    # Returns the timestamp of the pedal press, and also returns the time difference between pedal press and onset. 
    def check_emg_onset(self): 
        self.searching_rp = True #Prevents messing up with the index of the array by adding more things. 
        found = False
        total_size = len(self.emg_history)
        i = total_size - 3 #index position from back.
        return_index = -1
        pedal_timestamp_str = ''
        press_onset_diff = -1
        while(not found and not i <= 0) :
            if(self.emg_history[i+1]['data'] == 1 and self.emg_history[i]['data'] == 0):
                found = True
                return_index = i #change index position to the first
                self.searching_rp = False
                # check if the difference between emg onset and pedal press makes sense
                # between 100 ms and 1 s
                # Substring -6 to get the last six digits SS:FFF
                onset_timestamp = float(self.eeg_history[return_index]['matlab_timestamp'][-6:]) * 1000
                pedal_timestamp_str = self.eeg_history[total_size - 1]['matlab_timestamp']
                pedal_timestamp = float(pedal_timestamp_str[-6:]) * 1000
                press_onset_diff = pedal_timestamp - onset_timestamp
                print(press_onset_diff)
                # if press_onset_diff > 1000 or press_onset_diff < 100:
                    # return_index = -1
            
            i -= 1
        return return_index, pedal_timestamp_str, press_onset_diff

    def present_stimulus(self):
        threading.Thread(target = self.draw_fixation_cross).start() #draw cross
        pygame.time.delay(2000) #delay for 2 seconds then white circle         
        threading.Thread(target = self.draw_circle, args=[self.white_color]).start() #draw white circle
        # sends a parallel log to show that the trial starts. 
        self.send_parallel_log(self.marker_trial_start)

    def draw_circle(self, color):
        self.screen.fill(self.background_color)
        pygame.draw.circle(self.screen, color, (self.screen_center[0], self.screen_center[1]), self.radius)
        pygame.display.update()
        self.last_circle_shown = pygame.time.get_ticks()

    def draw_fixation_cross(self):
        self.screen.fill(self.background_color)
        vertical_line = pygame.Surface((2, self.cross_length))
        horizontal_line = pygame.Surface((self.cross_length, 2))
        self.screen.blit(horizontal_line, (self.screen_center[0] - (self.cross_length/2), self.screen_center[1]))
        self.screen.blit(vertical_line, (self.screen_center[0], self.screen_center[1] - (self.cross_length/2)))
        pygame.display.update()
        self.last_cross_shown = pygame.time.get_ticks()

    def draw_text(self, str_value):
        t = threading.Thread(target = self.render_text, args=[str_value]) #runs it on another thread
        t.start()

    def render_text(self, text):
        self.screen.fill(self.background_color)
        disp_text = self.font_text.render(text, 0, self.text_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2] / 2, self.screen_center[1] - textsize[3] / 2))
        pygame.display.update()

    def send_parallel_log(self, event):
        self.send_parallel(event)
        self.log(self.marker_identifier[event])

    def log(self, print_str):
        now = pygame.time.get_ticks()
        log = '[%4.3f sec] %s' % (now / 1000.0, print_str)
        print(log)
        return log

if __name__ == '__main__':
    fb = ReadinessFeedback()
    fb.on_init()
    fb.on_play()
