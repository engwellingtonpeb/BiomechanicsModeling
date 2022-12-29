'''
Federal University of Rio de Janeiro
Biomedical Engineering Graduate Program - COPPE

Student: Wellington Pinheiro, MSc.
Advisor: Luciano Menegaldo, PhD.
'''

import opensim as osim
import pandas as pd
import math
import numpy as np
from pytictoc import TicToc
ETA=TicToc()

import warnings
warnings.filterwarnings("ignore")


model=osim.Model('models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim')

state=model.initSystem()


# Set the initial muscle activations and muscle fiber lengths
muscleSet = model.getMuscles()
num_muscles=muscleSet.getSize()
num_states= model.getNumStateVariables()

states=[]

ETA.tic()
for i in range(num_states):
    txt=model.getStateVariableNames().getitem(i).split('/')
    label=txt[-2]+'_'+txt[-1]
    states.append(label)
ETA.toc()

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
ETA.tic()
columns = ['time'] + [coord.getName() for coord in model.getCoordinateSet()]
df = pd.DataFrame(columns=columns)
ETA.toc()




# Step through the simulation.
currentTime=state.getTime()
manager.initialize(state)
model.setUseVisualizer( True )
StateValues=np.empty(num_states)
IntegrationTime=[]
n=0
while (currentTime < finalTime):
    
    #Set muscle input
    for i in range(num_muscles):
        u=0.25+(1/7)*math.sin(currentTime) #muscle excitation
        muscleSet.get(i).setActivation(state, u)
    
    # Advance the simulation by one time step.
    currentTime=initialTime + n*Ts
    manager.integrate(currentTime)
    
    coord_values = [coord.getValue(state) for coord in model.getCoordinateSet()]
    df = df.append({'time': currentTime, **{coord.getName(): value for coord, value in zip(model.getCoordinateSet(), coord_values)}}, ignore_index=True)

    StateValues=np.append(StateValues,state.getY().to_numpy(),axis=0)
    IntegrationTime.append(currentTime)
    

    # Print the current time and the values of the model's coordinates.
    print(f"Time: {n}")
    n+=1

    
    
lin=len(IntegrationTime)+1
col=int(len(StateValues)/lin)

StateValues=np.resize(StateValues,(lin,col))
StateValues=np.delete(StateValues,0,axis=0)



df_full = pd.DataFrame(StateValues, columns=states)
df_full.insert(0,'Tempo',IntegrationTime, True)
# Print the dataframe.
# print(df)