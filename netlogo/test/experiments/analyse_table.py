#!/usr/bin/env python3
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
# for key in [
        # '[run number]',
        # '[step]',
# ]:
    # data[key] = data[key].astype("category")

## extract landuse_fractions
names = np.array(['missing','artificial','water','crop-annual','crop-perennial','scrub',
                  'intensive-pasture','extensive-pasture','native-forest','exotic-forest'])
fractions = list(zip(*[[float(x) for x in t.replace('[','').replace(']','').split(' ')]
                    for t in data['landuse-fraction']]))
for name,fraction in zip(names,fractions):
    data[f'fraction-{name}'] = fraction



landuse_fraction_keys = [key for key in list(data) if (re.match(r'^fraction-.*',key) and key != 'fraction-missing')]
    

# ## plot landuse_fraction distribution over runs at the beginning and
# ## end steps
# fig = plt.figure(2)
# fig.clf()
# fig.suptitle('Distribution of landuse fractions at beginning and end of multiple runs')
# iax = 0
# for key in list(data):
#     if r:=re.match(f'^fraction-(.*)',key):
#         name = r.group(1)
#         if name == 'missing': continue
#         iax += 1
#         ax = fig.add_subplot(3,3,iax)
#         for i,step in enumerate(
#                 (data['[step]'].min(),data['[step]'].max())):
#             l = ax.hist(
#                 data[key][data['[step]']==step]*100,
#                 10,
#                 label=f'step {step}',
#                 alpha=0.5)
#         ax.axvline(data[f'{name}-weight'][0],zorder=5,color='red',linestyle=':')
#         ax.set_title(name)
#         ax.set_xlim(0,70)
# ax.legend()

## plot landuse_fraction distribution over runs at the beginning and
## end steps
fig = plt.figure(2,figsize=(8.3,11.7))
fig.clf()
fig.suptitle('Land use fraction change over time')
iax = 0
for ikey,key in enumerate(landuse_fraction_keys):
    ax = fig.add_subplot(int(np.sqrt(len(landuse_fraction_keys))+1),int(np.sqrt(len(landuse_fraction_keys))),ikey+1)
    for irun,run in enumerate(np.unique(data['[run number]'])):
        datai = data[data['[run number]'] == run]
        l = ax.plot(datai['[step]'],datai[key])
        ax.set_title(key)

# fig.savefig(f'{table_file_name}.pdf')
fig.savefig(f'/tmp/t.pdf')
# # plt.show()    

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

