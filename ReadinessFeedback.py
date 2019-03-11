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
from FeedbackBase.gradient import fill_gradient
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
        self.time_trial_end = now
        self.trial_counter -= 1


    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()
        self.present_stimulus()


    def on_control_event(self, data):
        if self.on_trial:
            now = pygame.time.get_ticks()
            if data['pedal'] == 1:
                self.pedal_press()
            self.emg_state = data['emg']
            self.cfy_output = data['cl_output']
        if self.paused:
            if data['pedal'] == 1:
                self.unpause()


    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            self.update_bar()
            self.update_bars()
            if self.on_trial and not self.already_pressed and not self.this_prompt:
                self.keypressed = False
                self.pedal_press()
            if self.paused:
                self.keypressed = False
                self.unpause()
            if not self.on_trial:
                self.keypressed = False
                self.already_interrupted = False


    def pedal_press(self):
        self.already_pressed = True
        now = pygame.time.get_ticks()
        self.log('button press')


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
        fill_gradient(recct,  green,red, vertical=False)
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


if __name__ == "__main__":
    fb = ReadinessFeedback()
    fb.on_init()
    fb.on_play()
