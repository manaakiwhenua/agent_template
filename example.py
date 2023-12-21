## -*- compile-command: "time ./environment/run_in_conda_environment.bash python example.py" ; -*-

from agent_template import *

config = OmegaConf.load('example_config.yaml')


## branch according to  visualisation style


## run and model and show final output
if config['visualisation'] in ('window','pdf'):
    ## initialise model
    random.seed(config['random_seed'])
    model = LandUseModel(**config)
    # for farmer in model.farmers[:5]: print( farmer)
    # print( model)
    # model.print_config()
    ## perform 100 iterations
    for step in range(config['steps_to_run']):
        model.step()
    ## collect data
    data = model.get_data()
    farmers_initial = data['farmer'][data['farmer']['step']==1]
    ## plot initial land use as coloured patches
    if config['visualisation'] == 'window':
        mpl.use('QtAgg')
    else:
        mpl.use('Agg')
    mpl.rcParams |= {'figure.figsize':(5,5),
        'figure.subplot.bottom': 0.2,
        'figure.subplot.top': 0.95,
        'figure.subplot.left': 0.05,
        'figure.subplot.right': 0.95,
        'font.family': 'sans',}
    fig = mpl.pyplot.figure()
    ax = fig.gca()
    for i,agent in farmers_initial.iterrows():
        ax.add_patch(mpl.patches.Rectangle(
            (agent['x_coord'],agent['y_coord']), 1,1,
            color=model.config['land_use'][agent['land_use']]['color'],))
    ax.set_xlim(0,model.grid_length)
    ax.set_ylim(0,model.grid_length)
    ax.xaxis.set_ticks([])
    ax.yaxis.set_ticks([])
    for data in model.config['land_use'].values():
        ax.plot([],[],color=data['color'],label=data['label'])
    ax.legend(ncol=3,frameon=False,loc=(0,-0.2),fontsize='small')
    if config['visualisation'] == 'window':
        fig.show()
    elif config['visualisation'] == 'pdf':
        fig.savefig(config["output_directory"]+'/land_use.pdf')
    else:
        pass

## jupyterlab interactive visualisation
elif config['visualisation'] == 'jupyterlab':
    raise Exception(f"visualisation {config['visualisation']!r} is not implemented")

## solara web page
elif config['visualisation'] == 'solara':

    model_params = dict(config)

    # model_params = {
        # "N": {
           # "type": "SliderInt",
            # "value": 50,
            # "label": "Number of agents:",
            # "min": 10,
            # "max": 100,
            # "step": 1,
        # },
        # "width": 10,
        # "height": 10,
    # }

    def agent_portrayal(agent):
        return {"color": "tab:blue",
                "size": 50,}

    page = JupyterViz(
        LandUseModel,
        model_params,
        measures=[],
        name="Land use model", 
        agent_portrayal=agent_portrayal,
    )


else:
    assert False
