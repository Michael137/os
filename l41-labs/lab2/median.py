from scipy import stats
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import math

SIZES = [512 * 2 ** exp for exp in range (2, 16)]

'''
    TODO:
    Why is pipe peaking at 16k for single thread?: # of reads/writes? preempting? optimized for multiple threads? BIG_PIPE_SIZE? 32k/2 = 16k
'''
thread2_pipe = pd.read_pickle("pkls/mc_pipe_2thread.pkl")
proc2_pipe = pd.read_pickle("pkls/mc_pipe_2proc.pkl")

thread2_local = pd.read_pickle("pkls/mc_local_2thread.pkl")
proc2_local = pd.read_pickle("pkls/mc_local_2proc.pkl")

thread2_local_s = pd.read_pickle("pkls/mc_local_s_2thread.pkl")
proc2_local_s = pd.read_pickle("pkls/mc_local_s_2proc.pkl")

proc2_l1_hits_pipe = pd.read_pickle("pkls/ipc_ipc_static_2proc_pipe_runs_12_P_l1dmc_pmc_l1d_hits.pkl")
proc2_l1_refill_pipe = pd.read_pickle("pkls/ipc_ipc_static_2proc_pipe_runs_12_P_l1dmc_pmc_l1d_refill.pkl")
thread2_l1_hits_pipe = pd.read_pickle("pkls/ipc_ipc_static_2thread_pipe_runs_12_P_l1dmc_pmc_l1d_hits.pkl")
thread2_l1_refill_pipe = pd.read_pickle("pkls/ipc_ipc_static_2thread_pipe_runs_12_P_l1dmc_pmc_l1d_refill.pkl")

proc2_l1_hits_local = pd.read_pickle("pkls/ipc_ipc_static_2proc_local_runs_12_P_l1dmc_pmc_l1d_hits.pkl")
proc2_l1_refill_local = pd.read_pickle("pkls/ipc_ipc_static_2proc_local_runs_12_P_l1dmc_pmc_l1d_refill.pkl")
thread2_l1_hits_local = pd.read_pickle("pkls/ipc_ipc_static_2thread_local_runs_12_P_l1dmc_pmc_l1d_hits.pkl")
thread2_l1_refill_local = pd.read_pickle("pkls/ipc_ipc_static_2thread_local_runs_12_P_l1dmc_pmc_l1d_refill.pkl")


toCompare = {}
pvalues = []
pvalues_ttest = []
pvalues_mwu = []
for frame in proc2_local_s:
    size = frame['buffersize']
    if size not in toCompare:
        toCompare[size] = [frame['speeds']]
    else:
        toCompare[size] += frame['speeds']

for frame in proc2_local:
    size = frame['buffersize']
    if size not in toCompare:
        toCompare[size] = [frame['speeds']]
    else:
        toCompare[size].append(frame['speeds'])

ks = toCompare.keys()
ks.sort()
for k in ks:
    res = toCompare[k]
    stat, p, med, tbl = stats.median_test(res[0], res[1])
    ttest = stats.ttest_ind(res[0], res[1])
    pvalues.append(p)
    pvalues_ttest.append(ttest.pvalue)
    stat, p = stats.mannwhitneyu(res[0], res[1])
    pvalues_mwu.append(p)

    print(str(k) + ":\n\t" + str(ttest.pvalue)+ " | " + str(p))

fig=plt.figure(figsize=(15, 18))
#ax1 = fig.add_subplot(2,1,1)
#ax2 = fig.add_subplot(2,1,2)
ax2 = fig.gca()

ax2.semilogy(SIZES,pvalues_ttest)
ax2.set_ylabel("Student t-test p values (log)")
ax2.set_title("Student t-test for Statistical Difference Between Socketpair Configurations")
ax2.set_xlabel("Buffer Size (Bytes)")
ax2.axhline(y=0.05, linestyle="--", color='c', label = "p = 0.05")
ax2.legend(["p-value of local with and without matching", "p = 0.05"])
ax2.grid()
ax2.set_xscale('log')

fig.savefig("loacl_s_2proc.png")
