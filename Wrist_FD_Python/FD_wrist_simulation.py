'''
Federal University of Rio de Janeiro
Biomedical Engineering Program

Author: Wellington Pinheiro, MSc.
Advisor: Luciano Menegaldo, PhD.

This script runs a basic forward dynamics openloop simulation of wrist movement
it uses opensim integrators. Test18/02
'''

import opensim as osim
import numpy as np
import pandas as pd

model=osim.Model("D:\\22_BiomechRepo\\BiomechanicsModeling\\RL_WristPython\\models\\MoBL_ARMS_tutorial_33\\MoBL-ARMS OpenSim tutorial_33\\ModelFiles\\MoBL_ARMS_module2_4_allmuscles.osim")
state=model.initSystem()

manager=osim.Manager(model)


start_time=0.0 #seconds
end_time=1.0 #seconds
time_step=0.01 #seconds




# Step through the simulation.
while (manager.getTime() < manager.getFinalTime()):
    # Set the control signal for each muscle.
    for muscle in model.getMuscles():
        # Update the muscle's control signal to a function of time.
        muscle.updInput(state, 0.5 + 0.5 * math.sin(manager.getTime()))

    # Advance the simulation by one time step.
    manager.integrate(manager.getTime() + 0.01)
    # Print the current time and the values of the model's coordinates.
    time = manager.getTime()
    print(f"Time: {time}")
    for coord in model.getCoordinates():
        print(f"{coord.getName()}: {coord.getValue(state)}")