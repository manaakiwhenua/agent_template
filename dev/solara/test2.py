import os
os.system('GIT_SSL_NO_VERIFY=true pip install --quiet -U git+https://github.com/projectmesa/mesa-examples#egg=mesa-models')

import mesa
from mesa_models.boltzmann_wealth_model.model import BoltzmannWealthModel
from mesa.experimental import JupyterViz

model_params = {
    "N": {
       "type": "SliderInt",
        "value": 50,
        "label": "Number of agents:",
        "min": 10,
        "max": 100,
        "step": 1,
    },
    "width": 10,
    "height": 10,
}

def agent_portrayal(agent):
    return {
        "color": "tab:blue",
        "size": 50,
    }

page = JupyterViz(
    BoltzmannWealthModel,
    model_params,
    measures=["Gini"],
    name="Money Model",
    agent_portrayal=agent_portrayal,
)
# This is required to render the visualization in the Jupyter notebook
page
from matplotlib import pyplot as plt
# plt.show()
plt.savefig('t.pdf')
