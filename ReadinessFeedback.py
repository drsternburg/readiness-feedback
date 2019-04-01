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
import matplotlib.pyplot as plt
import math
import threading
import time

class ReadinessFeedback(PygameFeedback):
    
    def init(self):
        PygameFeedback.init(self)

        ########################################################################
        self.FPS = 200
        self.screenPos = [0, 0]
        self.screenSize = [1000, 1000]
        self.screen_center = [self.screenSize[0] / 2, self.screenSize[1] / 2]
        self.caption = "ReadinessFeedback"

        self.background_color = [127, 127, 127]
        self.text_fontsize = 75
        self.text_color = [64, 64, 64]
        self.char_fontsize = 100
        self.char_color = [0, 0, 0]
        self.white_color = [255,255,255]
        self.red_color = [225, 0, 0]
        self.radius = 100

        self.pause_text = 'Press pedal to start...'
        self.paused = True
        self.on_trial = False
        self.on_training = False #This is used to control the offline or online stage. 
        self.training_counter = 0
        self.max_trial_training = 100

        ########################################################################

        self.marker_keyboard_press = 199
        self.marker_quit = 255
        self.marker_base_start = 10
        self.marker_base_interruption = 20
        self.marker_trial_end = 30
        self.marker_prompt = 40

        ########################################################################
        # MAIN PARAMETERS TO BE SET IN MATLAB

        self.listen_to_keyboard = 1
        self.pause_every_x_events = 2
        self.end_after_x_events = 6

        ########################################################################

        # logic parameters
        self.emg_history = []
        self.eeg_history = []
        self.rp_history = []
        self.last_cross_shown = pygame.time.get_ticks()
        self.last_circle_shown = pygame.time.get_ticks()

        #########################################################################
        self.first_100_eeg = [3.40158,5.91582,8.72199,2.09857,1.57752,2.13866,1.31238,0.6742,-0.860305,0.869217,-2.20397,-0.427483,3.09122,-3.15091,6.29236,3.96954,-2.99037,-0.372976,3.0263,3.8923,-0.655221,1.86118,2.16084,-0.00743317,-10.7251,0.493279,0.844872,2.12802,4.46754,2.9867,2.67655,4.06675,1.01152,2.13234,3.17019,-0.483233,2.92781,3.2214,-3.94281,-1.15404,4.38632,1.29367,4.01247,-0.0690076,6.65976,6.36116,-0.479293,6.05266,5.24286,4.2689,-3.3575,4.44705,1.55116,2.94615,2.08329,4.34001,2.62014,5.26946,1.24628,2.23645,1.19922,-0.454266,5.87512,4.72588,6.4719,6.14339,6.07847,8.75295,7.29186,5.12702,11.5874,1.30933,1.30272,-1.92392,-2.79681,0.776014,7.42855,0.952247,-0.469118,5.27124,3.45942,1.59118,3.96028,3.67294,3.03981,1.52358,2.41185,2.48132,2.03066,6.84007,4.25418,3.03598,2.84473,3.6167,1.53169,6.81807,2.31844,1.12883]
        self.first_100_eeg = sorted(self.first_100_eeg)
        self.mu = np.average(self.first_100_eeg)
        self.std = np.std(self.first_100_eeg)
        self.one_std_val = 25
        self.mean_value = 50
        # pdf = stats.norm.pdf(self.first_100_eeg, mu, std)
        # plt.plot(self.first_100_eeg, pdf)
        # plt.show()


    def pre_mainloop(self):
        PygameFeedback.pre_mainloop(self)
        self.font_text = pygame.font.Font(None, self.text_fontsize)
        self.font_char = pygame.font.Font(None, self.char_fontsize)
        self.trial_counter = 0
        self.block_counter = 0
        self.move_counter = 0
        self.idle_counter = 0
        self.pedalpress_counter = 0
        self.reset_trial_states()
        self.on_pause()
        self.render_text(self.pause_text)

    def reset_trial_states(self):
        self.time_trial_end = float('infinity')
        self.time_trial_start = float('infinity')
        self.yellow_until = float('infinity')
        self.redgreen_until = float('infinity')
        self.yellow_on = False
        self.redgreen_on = False
        self.already_interrupted = False
        self.already_interrupted_silent = False
        self.this_prompt = False
        self.this_premature = False

    def post_mainloop(self):
        PygameFeedback.post_mainloop(self)

    def on_pause(self):
        self.log('Paused. Waiting for participant to continue...')
        self.time_trial_start = float('infinity')
        self.paused = True
        self.on_trial = False
        self.render_text(self.pause_text)

    def unpause(self):
        self.log('Starting block ' + str(self.block_counter + 1))
        now = pygame.time.get_ticks()
        self.paused = False
        self.on_trial = True
        self.time_trial_end = now
        self.trial_counter -= 1 
        self.present_stimulus()

    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()

    def on_control_event(self, data):
        if self.on_trial and not self.paused and not self.on_training:
            now = pygame.time.get_ticks()
            if u'emg' in data:
                self.emg_history.append(data[u'emg'])
            if u'cl_output' in data:
                self.eeg_history.append(data[u'cl_output'])

        if u'pedal' in data and data[u'pedal'] == 1.0 and not self.paused:
            self.pedal_press()
            
    def transform_rp(self, rp):
        z_score = (rp - self.mu) / self.std
        return int(round(self.one_std_val * z_score + self.mean_value))

    def write_to_file(self, content):
        f = open("rp-test.txt", "a")
        f.write(content)
        f.write("\n")
        f.close()

    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            if self.on_trial and not self.this_prompt:
                self.pedal_press()
            if self.paused:
                self.unpause()
            if not self.on_trial:
                self.already_interrupted = False
            self.keypressed = False
            
            
    def pedal_press(self):
        now = pygame.time.get_ticks()
        self.log('pedal press')

        # restart the trial if they press it for less than 2 seconds
        if(now - self.last_circle_shown < 2000):
            self.draw_text("Too quick, retry again")
            pygame.time.delay(1000) #delay for 1 second      
            
        else: 
            threading.Thread(target = self.draw_circle, args=[self.red_color]).start() #presents red circle
            pygame.time.delay(1000) #delay for 1 second    

            self.pedalpress_counter += 1

            if self.on_training:
                self.training_counter +=1
                if self.training_counter == self.max_trial_training :
                    self.draw_text("Finished training...")
                    return
            else:
                # Calculating the RP based on EEG and EMG history
                found = False
                i = len(self.emg_history) - 3 #index position from last
                while(not found and not i <= 0) :
                    if(self.emg_history[i+1] == 1 and self.emg_history[i] == 0):
                        found = True
                    i -= 1

                i = len(self.eeg_history) - i #change index position to the first
                # rp = self.eeg_history[i]
                rp = np.random.uniform(np.min(self.first_100_eeg), np.max(self.first_100_eeg), 1)[0]

                rp_val_transformed = self.transform_rp(rp)

                # write to file, the necessary info about the rp
                content_to_write = self.log(" | " + str(rp) + " | " + str(rp_val_transformed))
                self.write_to_file(content_to_write)
                # Present the RP value on screen
                self.draw_text(str(rp_val_transformed)) 
                pygame.time.delay(2000) #delay for 2 seconds then present the cross            

        self.present_stimulus()
        # Restart the history
        self.eeg_history = []
        self.emg_history = []

    def present_stimulus(self):
        threading.Thread(target = self.draw_fixation_cross).start() #draw cross
        pygame.time.delay(2500) #delay for 2.5 seconds then white circle         
        threading.Thread(target = self.draw_circle, args=[self.white_color]).start() #draw white circle

    def draw_text(self, str_value):
        t = threading.Thread(target = self.render_text, args=[str_value]) #runs it on another thread
        t.start()

    def draw_circle(self, color):
        self.screen.fill(self.background_color)
        pygame.draw.circle(self.screen, color, (self.screen_center[0], self.screen_center[1]), self.radius)
        pygame.display.update()
        self.last_circle_shown = pygame.time.get_ticks()

    def draw_fixation_cross(self):
        self.screen.fill(self.background_color)
        vertical_line = pygame.Surface((2, 250))
        horizontal_line = pygame.Surface((250, 2))
        self.screen.blit(horizontal_line, (self.screen_center[0] - (250/2), self.screen_center[1]))
        self.screen.blit(vertical_line, (self.screen_center[0], self.screen_center[1] - (250/2)))
        pygame.display.update()
        self.last_cross_shown = pygame.time.get_ticks()

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
        log = '[%4.2f sec] %s' % (now / 1000.0, print_str)
        print(log)
        return log

if __name__ == '__main__':
    fb = ReadinessFeedback()
    fb.on_init()
    fb.on_play()
