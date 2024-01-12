from copy import copy

import mesa
import matplotlib
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np

## acceptable file suffix to produce an image file
static_visualisation_filetypes = ('png','pdf','jpg','jpeg','tiff','svg')

def make_visualisation(model):
    """Use maptlotlib to make a static visualisation or interactive window."""
    data = model.get_data()
    config = model.config
    ## style and initialise figure
    if config['plot'] == 'window':
        mpl.use('QtAgg')
    elif config['plot'] in static_visualisation_filetypes:
        mpl.use('Agg')
    else:
        raise Exception('Invalid visualisation:', config['plot'])
    mpl.rcParams |= {
        'figure.figsize':(11.7,8.3,), # A4 landscape
        'figure.subplot.bottom': 0.2,
        'figure.subplot.top': 0.95,
        'figure.subplot.left': 0.05,
        'figure.subplot.right': 0.95,
        'font.family': 'sans',}
    fig = mpl.pyplot.figure()
    fig.clf()
    ## plot land use at requested steps
    steps = config['plot_steps']
    ## ensure a list of steps
    if isinstance(steps,int):
        steps = [steps]
    ## translate negative steps as indexed from the end 
    for i,step in enumerate(copy(steps)):
        if step < 0:
            max_steps = data['farmer']['step'].max()
            steps[i] = max_steps + step
    for step in steps:
        axes = _plot_land_use(model,step=step,fig=fig)
    ## dummy data for land use legend
    for data in model.config['land_use'].values():
        axes.plot([],[],color=data['color'],label=data['label'])
    ## land use legend
    leg = axes.legend(
        ncol=3,
        frameon=False,
        fontsize='large',
        handlelength=0,         # draw no lines
        ## figure coords
        bbox_to_anchor=(0.5,0),
        loc="lower center",
        bbox_transform=fig.transFigure,)
    ## color text
    handles,labels = axes.get_legend_handles_labels()
    for text,handle in zip(leg.get_texts(),handles):
        text.set_color(handle.get_color())

    ## output
    if config['plot'] == 'window': 
        plt.show()
    elif config['plot'] in static_visualisation_filetypes:
        ## static file
        filename = config["output_directory"]+'/land_use.'+config['plot']
        print(f'Saving file: {filename!r}')
        plt.savefig(filename)
    else:
        pass


def subplot(
        n=None,                 # subplot index, begins at 0, if None adds a new subplot
        ncolumns=None,          # how many colums (otherwise adaptive)
        nrows=None,          # how many colums (otherwise adaptive)
        ntotal=None,         # how many to draw in total (at least)
        fig=None,            # Figure object or number identifier
        **add_subplot_kwargs
):
    """Return axes n from figure fig containing subplots.\n If subplot
    n does not exist, return a new axes object, possibly shifting all
    subplots to make room for ti. If axes n already exists, then
    return that. If ncolumns is specified then use that value,
    otherwise use internal heuristics.  n IS ZERO INDEXED"""
    if fig is None:
        ## default to current fkgure
        fig = plt.gcf()
    elif isinstance(fig,int):
        fig = plt.figure(fig)
    old_axes = fig.axes           # list of axes originally in figure
    old_nsubplots = len(fig.axes) # number of subplots originally in figure
    if n is None:
        ## new subplot
        n = old_nsubplots
    if ntotal is not None and ntotal > old_nsubplots:
        ## current number of subplot is below ntotal, make empty subplots up to this number
        ax = subplot(ntotal-1,ncolumns,nrows,fig=fig,**add_subplot_kwargs)
        old_nsubplots = len(fig.axes) # number of subplots originally in figure
    if n < old_nsubplots:
        ## indexes an already existing subplot - return that axes
        ax = fig.axes[n]
    elif n > old_nsubplots:
        ## creating empty intervening subplot then add the requested new one
        for i in range(old_nsubplots,n):
            ax = subplot(i,ncolumns,nrows,fig=fig,**add_subplot_kwargs)
    else:
        ## add the nenew subplot 
        nsubplots = old_nsubplots+1
        if ncolumns is not None and nrows is not None:
            columns,rows = ncolumns,nrows
        elif ncolumns is None and nrows is None:
            rows = int(np.floor(np.sqrt(nsubplots)))
            columns = int(np.ceil(float(nsubplots)/float(rows)))
            if fig.get_figheight()>fig.get_figwidth(): 
                rows,columns = columns,rows
        elif ncolumns is None and nrows is not None:
            rows = nrows
            columns = int(np.ceil(float(nsubplots)/float(rows)))
        elif ncolumns is not None and nrows is None:
            columns = ncolumns
            rows = int(np.ceil(float(nsubplots)/float(columns)))
        else:
            raise Exception("Impossible")
        ## create new subplot
        ax = fig.add_subplot(rows,columns,nsubplots,**add_subplot_kwargs)
        ## adjust old axes to new grid of subplots
        gridspec = matplotlib.gridspec.GridSpec(rows,columns)
        for axi,gridspeci in zip(fig.axes,gridspec):
            axi.set_subplotspec(gridspeci)
    ## set to current axes
    fig.sca(ax)  
    ## set some other things to do if this is a qfig
    if hasattr(fig,'_my_fig') and fig._my_fig is True:
        ax.xaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%0.10g'))
        ax.grid(True)
    return ax 

def _plot_land_use(model,step=None,fig=None,axes=None):
    """Plot land use at some step (defaults to last) on a new axes."""
    d = model.get_data()
    d = d['farmer']
    config = model.config
    ## get data for one step, default to last
    if step is None:
        step = d['step'].max()
    d = d[d['step']==step]
    ## make new axes
    if axes is None:
        axes = subplot(fig=fig)
    ## plot

    if isinstance(model.space,mesa.space.SingleGrid):
        ## plot grid points as square patches
        for i,agent in d.iterrows():
            axes.add_patch(mpl.patches.Rectangle(
                (agent['x_coord'],agent['y_coord']), 1,1,
                color=model.config['land_use'][agent['land_use']]['color'],))
        axes.xaxis.set_ticks([])
        axes.yaxis.set_ticks([])
        axes.set_xlim(d['x_coord'].min(),d['x_coord'].max())
        axes.set_ylim(d['y_coord'].min(),d['y_coord'].max())

    elif isinstance(model.space,mesa.space.NetworkGrid):
        ## plot vector shapes
        graph = model.space.G
        for node_id in graph.nodes:
            node = graph.nodes[node_id]
            geometry = node['geometry']
            farmer = node['farmer']
            color = model.config['land_use'][farmer.land_use]['color']
            geometry.plot(color=color,ax=axes)
        ## test plot neighbours
        # i =9
        # for farmer in model.space.get_neighbors(i,include_center=False  ):
            # geometry = graph.nodes[farmer.pos]['geometry']
            # geometry.plot(color='black',ax=axes)
        # geometry = graph.nodes[i]['geometry']
        # geometry.plot(color='red',ax=axes)
        

    else:
        assert False


    return axes
