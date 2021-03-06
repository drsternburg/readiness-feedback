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
        # Parameters to the bars visuals
        self.clf_input = 0
        self.clf_input_prev = 0
        self.dist = 0
        self.stat_bar_loc = 0
        self.bars_num = 15
        self.bars_values = np.zeros((self.bars_num))
        self.bars_colors = np.zeros((self.bars_num, 3))
        ########################################################################
        # MAIN PARAMETERS TO BE SET IN MATLAB

        self.listen_to_keyboard = 1
        self.pause_every_x_events = 2
        self.end_after_x_events = 6

        ######################################################################## 
        # logic parameters
        # self.max_history = 10
        self.emg_history = []
        self.eeg_history = []

        ######################################################################## 
        # TESTING PURPOSES ONLY.
        self.add_ones = False
        # self.on_trial = True
        # self.paused = False

    def test_inject_data(self):
        # TESTING PURPOSES ONLY.
        self.eeg_history = []
        self.emg_history = []
        self.test_data = []
        for i in range(10):
            self.test_data.append(dict(
                emg=0,
                cl_output=np.random.rand(),
                pedal=0
            ))
        for i in range(5,10): 
            self.test_data[i][u'emg'] = 1
        # feed the control event 
        for i in range(10):
            self.on_control_event(self.test_data[i])

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

    def reset_trial_states(self):
        self.time_trial_end = float('infinity')
        self.time_trial_start = float('infinity')
        self.yellow_until = float('infinity')
        self.redgreen_until = float('infinity')
        self.yellow_on = False
        self.redgreen_on = False
        self.already_interrupted = False
        self.already_interrupted_silent = False
        self.already_pressed = False
        self.this_prompt = False
        self.this_premature = False

    def post_mainloop(self):
        PygameFeedback.post_mainloop(self)

    def on_pause(self):
        self.log('Paused. Waiting for participant to continue...')
        self.time_trial_start = float('infinity')
        self.paused = True
        self.on_trial = False

    def unpause(self):
        self.log('Starting block ' + str(self.block_counter + 1))
        now = pygame.time.get_ticks()
        self.paused = False
        self.on_trial = True
        self.already_pressed = False
        self.time_trial_end = now
        self.trial_counter -= 1 

    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()
        self.present_stimulus()

    def on_control_event(self, data):
        print("cl output from matlab %f", data[u'cl_output'])
        if self.on_trial and not self.paused:
            now = pygame.time.get_ticks()
            if self.add_ones:
                self.emg_history.append(1)
            else:
                self.emg_history.append(data[u'emg'])
            self.eeg_history.append(data[u'cl_output'])
        else:
            # not sure what to do here... 
            pass
            
    def get_current_rp(self):
        # TODO: add more logic stuff here before sending back the RP. 
        return np.average(self.rp)

    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            if self.on_trial and not self.already_pressed and not self.this_prompt:
                self.pedal_press()
            if self.paused:
                #### ONLY FOR TESTING
                self.add_ones = True
                #######
                self.unpause()
            if not self.on_trial:
                self.already_interrupted = False
            self.keypressed = False
            
            
    def pedal_press(self):
        now = pygame.time.get_ticks()
        self.log('pedal press')

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
        print(self.rp)
        print(self.get_current_rp())
        # Restart the history
        self.eeg_history = []
        self.emg_history = []

        # Updates the UI and status.  
        #### ONLY FOR TESTING
        self.add_ones = False
        #######
        self.already_pressed = True
        self.update_bar()
        self.update_bars()
        self.on_pause()

    def present_stimulus(self):
        self.screen.fill(self.background_color)
        # TODO: here a simple rectangle is drawn
        self.show_rect()
        self.show_bars()
        if self.paused:
            self.render_text(self.pause_text)
        # else:
            # if self.on_trial:
                # if self.this_prompt:
                #     self.render_text(self.prompt_text)
                # else:
                #     pass
                    # self.show_trafficlight()
            # else:
            #     pass
                # self.draw_fixcross()
        pygame.display.update()

    def show_rect(self):
        # TODO: here a simple rectangle is drawn

        blue = (0, 0, 255)
        red = (255, 0, 0)
        green = (0, 255, 0)
        grey = (0, 0, 0)
        recct = pygame.Surface((800, 50))
        # recct.fill(blue)
        self.fill_gradient(recct,  green,red, vertical=False)
        image_size = recct.get_size()

        rectt_small = pygame.Surface((50, 100))
        rectt_small.fill(grey)
        rectt_small_size = rectt_small.get_size()
        self.clf_input = np.random.rand(1)
        self.dist = (2 * self.clf_input[0] - 1) * image_size[0] / 2
        rectt_small_stat = pygame.Surface((50, 100))
        rectt_small_stat.fill( self.bars_colors[-1])
        rectt_small_stat_size = rectt_small_stat.get_size()

        # dist = np.random.choice([-1,1])*image_size[0]/2
        # self.screen.blit(recct,((self.screenSize[0] / 2 - image_size[0] / 2), (self.screenSize[1] / 2 - image_size[1] / 2)))
        self.screen.blit(recct, ((self.screenSize[0] / 2 - image_size[0] / 2), self.screenSize[1] - 500))
        self.screen.blit(rectt_small, (
            (self.screenSize[0] / 2 - rectt_small_size[0] / 2) + self.clf_input_prev, self.screenSize[1] - image_size[1] / 2 - 500))
        self.screen.blit(rectt_small_stat, ((self.screenSize[0] / 2 - rectt_small_size[0] / 2) + self.stat_bar_loc,
                                            self.screenSize[1] - image_size[1] / 2 - 500))

    def show_bars(self):
        bar_width = 20

        bar_max_length = 100
        recct = [pygame.Surface((bar_width, np.int(i*bar_max_length ))) for i in self.bars_values]
        image_sizes = [i.get_size() for i in recct]
        for ind, val in enumerate(recct):
            val.fill(self.bars_colors[ind])
            self.screen.blit(val, (
            ((self.screenSize[0] / self.bars_num) * (ind + 1)) -50, self.screenSize[1] - image_sizes[ind][1] - 150))

    def update_bars(self):
        image_size = 50
        new_bar = self.clf_input
        if new_bar >= self.bars_values[-1]:
            color = (255, 0, 0)
        if new_bar < self.bars_values[-1]:
            color = (0, 255, 0)
        self.bars_values = np.append( self.bars_values[1:],[new_bar])
        self.bars_colors = np.append(self.bars_colors[1:,:],[color],  axis=0)

        # self.bars_colors[0,:]=color
        # self.bars_values = np.random.random((self.bars_num))


    def update_bar(self):
        self.clf_input_prev = self.stat_bar_loc
        self.stat_bar_loc = self.dist


    def render_text(self, text):
        disp_text = self.font_text.render(text, 0, self.text_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2] / 2, self.screen_center[1] - textsize[3] / 2 -100))


    def send_parallel_log(self, event):
        self.send_parallel(event)
        self.log(self.marker_identifier[event])

    def log(self, print_str):
        now = pygame.time.get_ticks()
        print '[%4.2f sec] %s' % (now / 1000.0, print_str)

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
