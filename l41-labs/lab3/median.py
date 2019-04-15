from scipy import stats
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

LATENCIES = range(0, 45, 5)

lat_bw_s = pd.read_pickle("pkls/latency_vs_bandwidth_match_purge.pkl")
lat_bw = pd.read_pickle("pkls/latency_vs_bandwidth_purge.pkl")

def test(data1, data2, prop):
    toCompare = [0] * len(LATENCIES)
    # pvalues = []
    pvalues_ttest = []
    # pvalues_mwu = []
    for (frame, l) in zip(data1, LATENCIES):
            toCompare[l / 5] = [frame[prop]]

    for (frame, l) in zip(data2, LATENCIES):
            toCompare[l / 5].append(frame[prop])

    ctr = 0
    for k in toCompare:
        ttest = stats.ttest_ind(k[0], k[1])
        pvalues_ttest.append(ttest.pvalue)

        print(str(ctr * 5) + ":\n\t" + str(ttest.pvalue))
        ctr = ctr + 1
    return pvalues_ttest

toPlot = []
toPlot.append({'data':test(lat_bw_s, lat_bw, "speeds"), 'lbl': "matching vs. non-matching"})

fig=plt.figure(figsize=(18, 6))
#ax1 = fig.add_subplot(2,1,1)
#ax2 = fig.add_subplot(2,1,2)
ax2 = fig.gca()
ax2.grid()
ax2.set_ylabel("Student t-test p values (log)")
ax2.set_title("Student t-test for Latency (0-40ms) vs. Bandwidth Results")
ax2.set_xlabel("Latencies (ms)")
ax2.axhline(y=0.05, linestyle="--", color='c', label = "p = 0.05")
ax2.axvline(x=25, linestyle="--", color='r', label = "25 ms")

for pl in toPlot:
    ax2.semilogy(LATENCIES,pl['data'], label=pl['lbl'])
    # ax2.set_xscale('log')

ax2.legend(fancybox=True, framealpha=0.5, loc="best")

fig.savefig("lat_bw_ttest.png")
