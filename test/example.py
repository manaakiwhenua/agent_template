from agent_template import *
import os


## initialise and step model
model = LandUseModel(10)
for step in range(100):
    model.step()
    
## plot output
model_data = model.datacollector.get_model_vars_dataframe()
agent_data = model.datacollector.get_agent_vars_dataframe()
steps = np.unique([t[0] for t in agent_data.index])
agent_ids = np.unique([t[1] for t in agent_data.index])
steps_to_plot = steps[0:-1:int(len(steps)/9)]

fig0 = plt.figure(0)
fig0.clf()
fig1 = plt.figure(1)
fig1.clf()
subplot_ij = int(np.ceil(np.sqrt(len(steps_to_plot))))
for istep,step in enumerate(steps_to_plot):
    ax = fig0.add_subplot(subplot_ij,subplot_ij,istep+1)
    ax.hist(agent_data['intensity'][step])
    ax.set_xlim(0,1)
    ax.set_title(step)
    ax = fig1.add_subplot(subplot_ij,subplot_ij,istep+1)
    ax.imshow(np.asarray(agent_data['intensity'][step]).reshape((model.N,model.N)))
    ax.set_title(step)

fig2 = plt.figure(2)
fig2.clf()
ax = fig2.add_subplot(3,2,1)
ax.plot(model_data['climate_effect'])
ax.set_title('climate_effect')
ax.set_ylim(0,1)
ax.set_xlim(0,max(steps))
for ikey,key in enumerate((
        'intensity',
        'profit_motivation',
        'sustainability_motivation',
        'neighbour_motivation',
)):
    ax = fig2.add_subplot(3,2,ikey+2)
    ax.plot([np.mean(agent_data[key][step]) for step in steps])
    ax.set_title(key)
    ax.set_ylim(0,1)
    ax.set_xlim(0,max(steps))
    
plt.show()

# ## visualisation
# def agent_portrayal(agent):
    # return {
        # "color": "tab:blue",
        # "size": 50,
    # }

# # model_params = {
    # # "N": {
        # # "type": "SliderInt",
        # # "value": 50,
        # # "label": "Number of agents:",
        # # "min": 10,
        # # "max": 100,
        # # "step": 1,
    # # },
# # #    "width": 10,
# # #    "height": 10,
# # }

# # from mesa.experimental import JupyterViz

# # page = JupyterViz(
    # # LandUseModel,
    # # model_params,
    # # measures=["climate_effect"],
    # # name="Money Model",
    # # agent_portrayal=agent_portrayal,
# # )

# # page

print('test complete')
