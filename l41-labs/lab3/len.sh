#!/usr/local/bin/python3.6

# Bandwidth vs. Timestamps

data = {'2thread':[],'2thread_s':[]}
RUNS = 10
FLAGS = ""
EXE = "ipc-static"
BUFFER_SIZES = []
TIMES = []
ENTRIES = []

text_file = open("test.log", "r")
lines = text_file.read().split("\n")
lines = [l.strip().split() for l in lines if "tcp_do_segment" in l]

# Aggregate info into list
# Order is important
for e in lines:
    entry = {}
    for kv in e:
        split = kv.split(':')
        if len(split) == 2:
            entry[split[0]] = split[1]
    ENTRIES.append(entry);

bws = []
cur_time = int(ENTRIES[0]["Time"])
for e in ENTRIES:
    diff = ((int(e["Time"]) - cur_time) / 1000000000)
    print(diff)
    if diff > 0.001:
        bws.append(e)
        cur_time = int(e["Time"])

bws = zip(bws[::2], bws[1::2])

for e in bws:
    tp = (int(e[0]["Seq"]) - int(e[1]["Seq"])) / (int(e[0]["Time"]) - int(e[1]["Time"]))

# print(ENTRIES[0]["Time"])
# print(ENTRIES[-1]["Time"])

# p = graph(BUFFER_SIZES,data['2proc'], RUNS, label="2proc off-cpu")
