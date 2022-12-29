'''
Federal University of Rio de Janeiro
Biomedical Engineering Graduate Program - COPPE

Student: Wellington Pinheiro, MSc.
Advisor: Luciano Menegaldo, PhD.
'''
# This code is based upon examples given on https://osim-rl.kidzinski.com/ of RL applications on Opensim's models. Parts from https://github.com/stanfordnmbl/osim-rl were taken and modified as need in agreement with MIT License terms. 


import opensim as osim
import gym
import os
from gym import spaces


## Create Opensim Interface
# wrap all needed from Opensim to work with RL

class osimModel(object):
    # Initialize simulation
    stepsize = 0.01

    model = None
    state = None
    state0 = None
    joints = []
    bodies = []
    brain = None
    verbose = False
    istep = 0
    
    state_desc_istep = None
    prev_state_desc = None
    state_desc = None
    integrator_accuracy = None

    maxforces = []
    curforces = []




#Create Opensim Model

model=osim.Model('models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim') 

#action Space Definition

action_space=spaces.Box(low=0, high=1, shape=(2,0))


class OsimWrisEnv():


    def __init__(self, model):
        pass

    def reset(self):
        pass

    def step(self, action):
        pass
 

