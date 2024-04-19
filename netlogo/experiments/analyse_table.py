## standard library
from pprint import pprint, pformat
## arrays and tables
import numpy as np
import pandas as pd
## visualisation
import matplotlib
matplotlib.use('QtAgg')
from matplotlib import pyplot as plt
plt.ion()
# plt.ioff()
import seaborn as sns

## read ouput
d = pd.read_csv(
    '~/in/ABM4CSL experiment_template-table.csv',
    skiprows=6,
)

## make some data categorical
for key in [
        '[run number]',
        '[step]',
]:
    d[key] = d[key].astype("category")

## plot facet grid in one step, new figure every time
# fg = sns.relplot(
    # data=d,
    # kind='line',
    # x='[step]',
    # y=['sum [value] of patches','sum [emissions] of patches'],
    # # y='sum [value] of patches',
    # # y='sum [emissions] of patches',
    # # col='[run number]',
    # hue='[run number]',
    # # min_y = 0,
    # # col_wrap=3,
    # # height=4,
    # # aspect=1.1,
    # ylim=(0,None),
    # )
# # fg.set(ylim=(0,None))
# fig.savefig('/tmp/t.pdf')

## custom grid
fig = plt.figure(1,clear=True)
for i,ykey in enumerate([
        'sum [value] of patches',
        'sum [emissions] of patches',
]):
    fig.add_subplot(2,1,i+1)
    ax = sns.lineplot(
        data=d,
        x='[step]',
        y=ykey,
        hue='[run number]',
        legend=False,
        )
    ax.set_ylim(0,None)

