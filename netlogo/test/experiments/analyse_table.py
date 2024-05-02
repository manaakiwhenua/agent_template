## standard library
from pprint import pprint, pformat
import re, sys
## arrays and tables
import numpy as np
import pandas as pd
## visualisation
import matplotlib
matplotlib.use('QtAgg')
from matplotlib import pyplot as plt
# plt.ion()
# plt.ioff()
import seaborn as sns

table_file_name = sys.argv[1]

## read ouput
data = pd.read_csv(table_file_name,skiprows=6)

## make some data categorical
for key in [
        '[run number]',
        '[step]',
]:
    data[key] = data[key].astype("category")

    
## extract landuse_fractions
names = np.array(['missing','artificial','water','crop-annual','crop-perennial','scrub',
                  'intensive-pasture','extensive-pasture','native-forest','exotic-forest'])
fractions = list(zip(*[[float(x) for x in t.replace('[','').replace(']','').split(' ')]
                    for t in data['landuse-fraction']]))
for name,fraction in zip(names,fractions):
    data[f'fraction-{name}'] = fraction
    
## plot landuse_fraction distribution
fig = plt.figure(2)
fig.clf()
iax = 0
for key in list(data):
    if r:=re.match(f'^fraction-(.*)',key):
        name = r.group(1)
        if name == 'missing': continue
        iax += 1
        ax = fig.add_subplot(3,3,iax)
        l = ax.hist(data[key]*100,10,label=name)
        ax.set_title(name)
        ax.axvline(data[f'{name}-weight'][0],zorder=5,color='red',linestyle=':')
        ax.set_xlim(0,70)
ax.legend()

fig.savefig(f'{table_file_name}.pdf')
# plt.show()    

## plot someting
# fig = plt.figure(1)
# fig.clf()
# ax = fig.gca()
# ax.plot(data['[run number]'],data['total-value'])

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
# fig = plt.figure(1,clear=True)
# for i,ykey in enumerate([
        # 'total-value',
        # 'total-emissions',
# ]):
    # fig.add_subplot(2,1,i+1)
    # ax = sns.lineplot(
        # data=data,
        # x='[step]',
        # y=ykey,
        # hue='[run number]',
        # legend=False,
        # )
    # ax.set_ylim(0,None)

