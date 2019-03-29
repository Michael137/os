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
# nums = [int(n) for n in lines if n is not '']
# data["2proc"] += nums

for e in lines:
    for kv in e:
        split = kv.split(':')
        entry = {}
        if len(split) == 2:
            entry[split[0]] = split[1]
            ENTRIES.append(entry);

print(ENTRIES)
# p = graph(BUFFER_SIZES,data['2proc'], RUNS, label="2proc off-cpu")
