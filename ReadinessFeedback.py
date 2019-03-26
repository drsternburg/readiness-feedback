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

        self.pause_text = 'Pause. Press pedal to continue...'
        self.paused = True
        self.on_trial = False

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
        self.draw_fixation_cross()
        self.paused = False
        self.on_trial = True
        self.time_trial_end = now
        self.trial_counter -= 1 

    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()

    def on_control_event(self, data):
        if self.on_trial and not self.paused:
            now = pygame.time.get_ticks()
            if u'emg' in data:
                self.emg_history.append(data[u'emg'])
            if u'cl_output' in data:
                self.eeg_history.append(data[u'cl_output'])
            if u'pedal' in data:
                if data[u'pedal'] == 1:
                    self.pedal_press()
        else:
            # not sure what to do here... 
            pass
            
    def get_current_rp(self):
        return np.average(self.rp)

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
        if(now - self.last_cross_shown < 2000):
            self.draw_text("Too quick, retry again")
            
        else: 
            self.pedalpress_counter += 1

            # Calculating the RP based on EEG and EMG history
            found = False
            i = len(self.emg_history) - 3 #index position from last
            while(not found and not i <= 0) :
                if(self.emg_history[i+1] == 1 and self.emg_history[i] == 0):
                    found = True
                i -= 1

            i = len(self.eeg_history) - i #change index position to the first
            if(len(self.eeg_history) > i-5):
                self.rp = self.eeg_history[i-5:i+1]
            else: 
                self.rp = self.eeg_history[:i+1]

            # Present the RP value on screen
            current_rp = str(self.get_current_rp)
            self.rp_history.append(current_rp)

            # str_rp = str(np.random.rand(1)[0])
            str_rp = str(self.get_current_rp())

            self.draw_text(str_rp)

        pygame.time.delay(2000) #delay for 2 seconds then present the cross            
        self.draw_fixation_cross()
        # Restart the history
        self.eeg_history = []
        self.emg_history = []

    def draw_text(self, str_value):
        t = threading.Thread(target = self.render_text, args=[str_value]) #runs it on another thread
        t.start()

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
        print '[%4.2f sec] %s' % (now / 1000.0, print_str)

if __name__ == '__main__':
    fb = ReadinessFeedback()
    fb.on_init()
    fb.on_play()
