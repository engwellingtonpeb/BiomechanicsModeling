'''
Federal University of Rio de Janeiro
Biomedical Engineering Graduate Program - COPPE

Student: Wellington Pinheiro, MSc.
Advisor: Luciano Menegaldo, PhD.
'''

import opensim as osim
import pandas as pd
import math


model=osim.Model('models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim')

state=model.initSystem()


# Set the initial muscle activations and muscle fiber lengths
muscleSet = model.getMuscles()
num_muscles=muscleSet.getSize()

# for i in range(num_muscles):
#     muscle = muscleSet.get(i)


# Set the initial time, final time and time step
initialTime = 0.0
Ts = 0.01
finalTime = .10


# Set the initial muscle inputs
# muscleInputs = osim.ArrayDouble(num_muscles)
# muscleInputs.set(0, 0.5)  # set the muscle input for the first muscle to 0.5


# Create a Manager object
manager = osim.Manager(model)
manager.setIntegratorAccuracy(1e-4)
manager.setIntegratorMethod(osim.Manager.IntegratorMethod_RungeKutta3)


# Create an empty Pandas DataFrame to store the results
columns = ['time'] + [coord.getName() for coord in model.getCoordinateSet()]
df = pd.DataFrame(columns=columns)

# for coord in model.getCoordinateSet():
#     print(f"{coord.getName()}: {coord.getValue(state)}")

# results = pd.DataFrame(columns=['time', 'positions', 'velocities', 'accelerations', 'muscle_activations', 'muscle_fiber_lengths','muscle_fiber_velocities'])


# Step through the simulation.
currentTime=state.getTime()
manager.initialize(state)
States={}
while (currentTime < finalTime):
    
    #Set muscle input
    for i in range(num_muscles):
        u=0.25+(1/7)*math.sin(currentTime)
        muscleSet.get(i).setActivation(state, u)
    
    # Advance the simulation by one time step.
    manager.integrate(currentTime + Ts)
    
    coord_values = [coord.getValue(state) for coord in model.getCoordinateSet()]
    df = df.append({'time': currentTime, **{coord.getName(): value for coord, value in zip(model.getCoordinateSet(), coord_values)}}, ignore_index=True)

    # Print the current time and the values of the model's coordinates.

    print(f"Time: {currentTime+Ts}")


    
    currentTime+=Ts



# Print the dataframe.
print(df)