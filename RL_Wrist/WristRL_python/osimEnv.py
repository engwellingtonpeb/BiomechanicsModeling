import opensim as osim
import gym
from gym import spaces

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

