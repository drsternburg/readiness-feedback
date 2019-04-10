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
        self.training_counter = 0

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
        self.one_std_val = 25
        self.mean_value = 50
    
        self.rp_dist_init = [3.40158,5.91582,8.72199,2.09857,1.57752,2.13866,1.31238,0.6742,-0.860305,0.869217,-2.20397,-0.427483,3.09122,-3.15091,6.29236,3.96954,-2.99037,-0.372976,3.0263,3.8923,-0.655221,1.86118,2.16084,-0.00743317,-10.7251,0.493279,0.844872,2.12802,4.46754,2.9867,2.67655,4.06675,1.01152,2.13234,3.17019,-0.483233,2.92781,3.2214,-3.94281,-1.15404,4.38632,1.29367,4.01247,-0.0690076,6.65976,6.36116,-0.479293,6.05266,5.24286,4.2689,-3.3575,4.44705,1.55116,2.94615,2.08329,4.34001,2.62014,5.26946,1.24628,2.23645,1.19922,-0.454266,5.87512,4.72588,6.4719,6.14339,6.07847,8.75295,7.29186,5.12702,11.5874,1.30933,1.30272,-1.92392,-2.79681,0.776014,7.42855,0.952247,-0.469118,5.27124,3.45942,1.59118,3.96028,3.67294,3.03981,1.52358,2.41185,2.48132,2.03066,6.84007,4.25418,3.03598,2.84473,3.6167,1.53169,6.81807,2.31844,1.12883]
        self.rp_dist_init = sorted(self.rp_dist_init)
        self.rect = pygame.Surface((50, 0))
        self.old_clf_input = 0
        self.clf_input = 0
        self.showing_rp = False

   

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
        self.draw_baseline()

    # def tick(self):
    #     now = pygame.time.get_ticks()
   
        # if self.listen_to_keyboard:
        #     self.on_keyboard_event()
    #     if not self.paused and not self.showing_rp:
    #         self.draw_baseline()
    #         # self.clf_input = np.random.uniform(np.min(self.rp_dist_init), np.max(self.rp_dist_init), 1)[0]    
    #         self.animate_rect()

    def on_control_event(self, data):
        # if u'interaction-signal' in data: #This is on init only, we would then find the mean and the std of the training data. 
        #     set_data = data[u'interaction-signal'][1]
        #     self.rp_dist_init = sorted(set_data[len(set_data)/2:])
        #     self.mu = np.average(self.rp_dist_init)
        #     self.std = np.std(self.rp_dist_init)
        clock = pygame.time.Clock()
        s = clock.tick(100)
        print(s)
        # if self.on_trial and not self.paused :
        #     now = pygame.time.get_ticks()
        #     if u'emg' in data:
        #         self.emg_history.append(data[u'emg'])
        #     if u'cl_output' in data:
        #         self.clf_input = data[u'cl_output']
        #         self.eeg_history.append(data[u'cl_output'])
                # self.draw_baseline()
                # threading.Thread(target = self.animate_rect).start() #presents red circle
        if u'pedal' in data and data[u'pedal'] == 1.0:
            self.pedal_press()
                
    def transform_rp(self, rp):
        z_score = (rp - self.mu) / self.std
        return int(round(self.one_std_val * z_score + self.mean_value))

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
        # self.showing_rp = True

        # # Calculating the RP based on EEG and EMG history
        # found = False
        # i = len(self.emg_history) - 3 #index position from last
        # while(not found and not i <= 0) :
        #     if(self.emg_history[i+1] == 1 and self.emg_history[i] == 0):
        #         found = True
        #     i -= 1

        # i = len(self.eeg_history) - i #change index position to the first
        # rp = self.eeg_history[i]
        # # rp = np.random.uniform(np.min(self.rp_dist_init), np.max(self.rp_dist_init), 1)[0]

        # # I need to show it now on the screen.
        # self.draw_text(str(rp))
        # pygame.time.delay(2000) #delay for 2 seconds then present the cross            
        # self.showing_rp = False
        # # Restart the history
        # self.eeg_history = []
        # self.emg_history = []

    def animate_rect(self):
        light_red = (255, 105, 97)
        dark_red = (50, 20, 20)
        light_green = (178, 236, 93)
        dark_green = (65, 72, 51)

        height = abs(self.clf_input) * 10 + 1
        self.rect = pygame.Surface((50, height))   

        if(self.clf_input > 0):
            self.fill_gradient(self.rect, light_red, dark_red, vertical=True)
            self.screen.blit(self.rect, (self.screen_center[0] - (50/2), self.screen_center[1] + 2))
        else:
            self.fill_gradient(self.rect, dark_green, light_green, vertical=True)
            self.screen.blit(self.rect, (self.screen_center[0] - (50/2), self.screen_center[1] - height))
        pygame.display.flip()

    def draw_baseline(self):
        self.screen.fill(self.background_color)
        horizontal_line = pygame.Surface((100, 2))
        self.screen.blit(horizontal_line, (self.screen_center[0] - (100/2), self.screen_center[1]))
        pygame.display.update()
        self.last_cross_shown = pygame.time.get_ticks()

    def draw_text(self, str_value):
        t = threading.Thread(target = self.render_text, args=[str_value]) #runs it on another thread
        t.start()

    def render_text(self, text):
        disp_text = self.font_text.render(text, 0, self.text_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2] / 2, self.screen_center[1] - textsize[3] + 100 / 2))
        pygame.display.update()

    def send_parallel_log(self, event):
        self.send_parallel(event)
        self.log(self.marker_identifier[event])

    def log(self, print_str):
        now = pygame.time.get_ticks()
        log = '[%4.2f sec] %s' % (now / 1000.0, print_str)
        print(log)
        return log
    
    ###########################################################################################################################
    #  fill a surface with a gradient pattern
    # Parameters:
    # color -> starting color
    # gradient -> final color
    # rect -> area to fill; default is surface's rect
    # vertical -> True=vertical; False=horizontal
    # forward -> True=forward; False=reverse
    
    # Pygame recipe: http://www.pygame.org/wiki/GradientCode
    def fill_gradient(self, surface, color, gradient, rect=None, vertical=True, forward=True):
        if rect is None: rect = surface.get_rect()
        x1,x2 = rect.left, rect.right
        y1,y2 = rect.top, rect.bottom
        if vertical: h = y2-y1
        else:        h = x2-x1
        if forward: a, b = color, gradient
        else:       b, a = color, gradient
        rate = (
            float(b[0]-a[0])/h,
            float(b[1]-a[1])/h,
            float(b[2]-a[2])/h
        )
        fn_line = pygame.draw.line
        if vertical:
            for line in range(y1,y2):
                color = (
                    min(max(a[0]+(rate[0]*(line-y1)),0),255),
                    min(max(a[1]+(rate[1]*(line-y1)),0),255),
                    min(max(a[2]+(rate[2]*(line-y1)),0),255)
                )
                fn_line(surface, color, (x1,line), (x2,line))
        else:
            for col in range(x1,x2):
                color = (
                    min(max(a[0]+(rate[0]*(col-x1)),0),255),
                    min(max(a[1]+(rate[1]*(col-x1)),0),255),
                    min(max(a[2]+(rate[2]*(col-x1)),0),255)
                )
                fn_line(surface, color, (col,y1), (col,y2))



if __name__ == '__main__':
    fb = ReadinessFeedback()
    fb.on_init()
    fb.on_play()
