import matplotlib
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np

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
