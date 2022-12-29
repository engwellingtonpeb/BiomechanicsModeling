'''
Federal University of Rio de Janeiro
Biomedical Engineering Graduate Program - COPPE

Student: Wellington Pinheiro, MSc.
Advisor: Luciano Menegaldo, PhD.
'''
# This code is based upon examples given on https://osim-rl.kidzinski.com/ of RL applications on Opensim's models. Parts from https://github.com/stanfordnmbl/osim-rl were taken and modified as need in agreement with MIT License terms. 

import gym
import opensim as osim

class OpenSimEnv(gym.Env):
    """Custom RL environment for OpenSim."""
    def __init__(self):
        # Load the model from a file.
        self.model = osim.Model('models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim')

        # Create an integrator.
        self.integrator = osim.RungeKuttaMersonIntegrator(self.model.getSystem())
        
        # Set up the simulation.
        self.state = self.model.initSystem()
        self.manager = osim.Manager(self.model)
        self.manager.setIntegrator(self.integrator)
        self.manager.setInitialTime(0)
        self.manager.setFinalTime(1)
        
        # Set the action and observation space.
        self.action_space = gym.spaces.Box(low=-1, high=1, shape=(self.model.getNumActuators(),), dtype=float)
        self.observation_space = gym.spaces.Box(low=-1, high=1, shape=(self.model.getNumCoordinates(),), dtype=float)
        
        # Set the initial state.
        self.current_state = self.get_observation()

    def step(self, action):
        pass
        # """Take a step in the environment."""
        # # Set the control signal for each actuator.
        # for actuator, control in zip(self.model.getActuators(), action):
        #     actuator.setControl(self.state, control)
        # # Advance the simulation by one time step.
        # self.manager.integrate(self.manager.getTime() + 0.01)
        # # Get the new state and reward.
        # new_state = self.get_observation()
        # reward = self.get_reward(new_state)
        # # Check if the episode is done.
        # done = self.is_done()
        # # Return the new state, reward, done flag, and additional information.
        # return new_state, reward, done, {}

    def reset(self):
        """Reset the environment to the initial state."""
        pass
