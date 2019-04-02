import json
import sys
import os


argv = sys.argv
id_start = int(argv[1])
id_stop = int(argv[2])

assert id_start <= id_stop

# python node_1/pi_main_2.py node_1 & python node_2/pi_main_2.py node_2 & python node_3/pi_main_2.py node_3 & python node_4/pi_main_2.py node_4 && fg

a = ['python3 node_{0}/pi_main_2.py node_{0}'.format(i) for i in range(id_start, id_stop+1)]
cmd = str.join(' & ', a)
cmd += ' && fg'

with open("run.sh", "w") as myfile:
        myfile.write(cmd)


path = os.getcwd()

nodes = ['node_{}'.format(i) for i in range(id_start, id_stop)]
files = ['pi_node.py', 'pi_main_2.py']

for i in range(id_start, id_stop+1):
    node = 'node_{}'.format(i)
    os.mkdir('{}/{}'.format(path, node))
    data = {
        "id": i
    }
    with open('{}/{}/node_id.json'.format(path, node), 'w') as outfile:
        json.dump(data, outfile)
    for file_ in files:
        os.link("{}/{}".format(path, file_), "{}/{}/{}".format(path, node, file_)) 
