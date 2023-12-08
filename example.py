## -*- compile-command: "time ./environment/python_env/bin/python example.py" ; -*-
# import matplotlib
# matplotlib.use('QtAgg')
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
from agent_template import *
import pandas as pd

config = OmegaConf.load('example_config.yaml')

random.seed(3142)
model = LandUseModel(config)
# for farmer in model.farmers[:5]: print( farmer)
# print( model)
# model.print_config()

# ## perform 100 iterations
for step in range(10):
    model.step()
# print( model.collected_data['step'])

## collect data
data = model.get_data()
farmers_initial = data['farmer'][data['farmer']['step']==1]

## plot initial land use as coloured patches
plt.rcParams |= {
    'figure.figsize':(5,5),
    'figure.subplot.bottom': 0.2,
    'figure.subplot.top': 0.95,
    'figure.subplot.left': 0.05,
    'figure.subplot.right': 0.95,
    'font.family': 'sans',
}
fig = plt.figure(0,figsize=(5,5))
fig.clf()
ax = fig.gca()
for i,agent in farmers_initial.iterrows():
    ax.add_patch(Rectangle(
        (agent['x_coord'],agent['y_coord']), 1,1,
        color=model.config['land_use'][agent['land_use']]['color'],))
ax.set_xlim(0,model.grid_length)
ax.set_ylim(0,model.grid_length)
ax.xaxis.set_ticks([])
ax.yaxis.set_ticks([])

for data in model.config['land_use'].values():
    ax.plot([],[],color=data['color'],label=data['label'])
ax.legend(ncol=3,frameon=False,loc=(0,-0.2),fontsize='small')
fig.savefig(f'output/land_use.pdf')
