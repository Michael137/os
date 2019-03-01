from scipy import stats
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('GTKAgg')
import matplotlib.pyplot as plt

SIZES = [512 * 2 ** exp for exp in range (2, 16)]

'''
    TODO:
        for each thread mode
            local vs pipe
            local vs local -s
            pmc for local and local -s
            pmc for pipe and local
'''
lcl_s = pd.read_pickle("pkls/pipe_2thread.pkl")
lcl = pd.read_pickle("pkls/pipe_2proc.pkl")

toCompare = {}
pvalues = []
pvalues_ttest = []
for frame in lcl_s:
    size = frame['buffersize']
    if size not in toCompare:
        toCompare[size] = [frame['speeds']]
    else:
        toCompare[size] += frame['speeds']

for frame in lcl:
    size = frame['buffersize']
    if size not in toCompare:
        toCompare[size] = [frame['speeds']]
    else:
        toCompare[size].append(frame['speeds'])

for size,res in toCompare.iteritems():
    stat, p, med, tbl = stats.median_test(res[0], res[1])
    print(str(size) + ":\n\t" + str(p))
    ttest = stats.ttest_ind(res[0], res[1])
    pvalues.append(p)
    pvalues_ttest.append(ttest.pvalue)

fig=plt.figure()
ax1 = fig.add_subplot(2,1,1)
ax2 = fig.add_subplot(2,1,2)

line, = ax1.plot(pvalues, SIZES)
line, = ax2.plot(pvalues_ttest, SIZES)
ax1.set_yscale('log')
ax2.set_yscale('log')

fig.savefig("pipe_2thread_pipe_2proc.png")
