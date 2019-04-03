from defaults import argHandler #Import the default arguments
import json
import sys
import os




FLAGS = argHandler()
FLAGS.setDefaults()
FLAGS.parseArgs(sys.argv)
print(os.getcwd())

print(FLAGS)

id_start = int(FLAGS['s'])
id_stop = int(FLAGS['f'])
assert id_start <= id_stop

# python node_1/pi_main_2.py node_1 & python node_2/pi_main_2.py node_2 & python node_3/pi_main_2.py node_3 & python node_4/pi_main_2.py node_4 && fg

a = ['python3 main_v4.2.py --id {} --N {}'.format(i, FLAGS['N']) for i in range(id_start, id_stop)]
cmd = str.join(' & ', a)
cmd += ' && fg'

with open("run.sh", "w") as myfile:
        myfile.write(cmd)
