from scipy import stats
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import math

SIZES = [512 * 2 ** exp for exp in range (2, 16)]

'''
    TODO:
        for each thread mode
            local vs pipe
            local vs local -s
            pmc for local and local -s
            pmc for pipe and local
    Why is pipe peaking at 16k for single thread?: # of reads/writes? preempting? optimized for multiple threads? BIG_PIPE_SIZE? 32k/2 = 16k
'''
lcl_s = pd.read_pickle("pkls/local_2proc.pkl")
lcl = pd.read_pickle("pkls/local_2thread.pkl")

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
    ttest = stats.ttest_ind(res[0], res[1])
    pvalues.append(p)
    pvalues_ttest.append(ttest.pvalue)
    print(str(size) + ":\n\t" + str(ttest.pvalue))

fig=plt.figure()
#ax1 = fig.add_subplot(2,1,1)
#ax2 = fig.add_subplot(2,1,2)
ax2 = fig.gca()

ax2.semilogy(SIZES,pvalues_ttest)
ax2.set_ylabel("Student t-test p values (log)")
ax2.set_title("")
ax2.set_xlabel("Buffer Size (Bytes)")
ax2.axhline(y=0.05, linestyle="--", color='c', label = "p = 0.05")
ax2.legend(["2thread vs. 2proc p-values", "p = 0.05"])
ax2.grid()
#ax2.set_yscale('log')

fig.savefig("pipe_2thread_pipe_2proc.png")
