from pi_node import pi_node, PiTransitionDiagram
import paho.mqtt.client as paho
import time
import itertools
import json
import sys
import os
from pprint import pprint



argv = sys.argv
if len(argv) >= 3:
    id_start = int(argv[1])
    id_stop = int(argv[2])
    assert id_start <= id_stop
    node_list = list(range(id_start, id_stop+1))

    with open('node_id.json', 'w') as outfile:
            json.dump(node_list, outfile)
    print('Generated new node_list:')
    print(node_list)

print(os.getcwd())



# if len(sys.argv) == 2:
#     os.chdir(os.getcwd() + os.sep + sys.argv[1])
#     print(os.getcwd())
# broker_ip = '192.168.0.104'
# broker_ip = 'localhost'
# broker_ip = '10.1.199.251'
# broker_ip = '10.101.6.111'
broker_ip = '10.101.21.2'



with open('node_id.json') as f:
    my_id_list = json.load(f)
        
connflag = False
startflag = False
initflag = False
stopflag = False
nextflag = False

my_neighbours = []
node_set = {str(x) for x in range(60)}
paramet = {
        'alpha': [0.5, 0.5], # infect rate 
        'mu': [0.5, 0.5], # sleep s 
        'gamma': [0.1, 0.1], # rec rate 
        'lambda': [0.7, 0.2], # sleep I1 
        'kappa': [0.7, 0.2] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
    }

my_td = PiTransitionDiagram(paramet)
mqttc = paho.Client()

my_nodes = {node_id: pi_node(node_id, my_neighbours, my_td, mqttc, state='S_a') for node_id in my_id_list}


def on_connect(client, userdata, flags, rc):
    global connflag
    #if connection is successful, rc value will be 0
    print("Connection returned result: " + str(rc) )
    # print(flags)
    connflag = True

def on_message(client, userdata, msg): 
    print('not_expexted', msg.payload.decode())

def on_state(client, userdata, msg): 
    global my_nodes
    # print("-t {} | -p {}".format(msg.topic, msg.payload.decode()) )
    try:
        js = json.loads(msg.payload.decode())
        for my_node in my_nodes.values():
            my_node.handle_msg(js)
        # print(js)
    except Exception as e:
        print('Error: ', e)
    
def on_start(client, userdata, msg): 
    global startflag
    startflag = True
    print("Simulation started: {}".format(msg.payload))

def on_stop(client, userdata, msg): 
    global stopflag
    stopflag = True
    print("Stop command : {}".format(msg.payload))

def on_td(client, userdata, msg): 
    global my_nodes
    paramet = json.loads(msg.payload.decode())
    for my_node in mymy_nodes:
        my_nodes.pi_td = PiTransitionDiagram(paramet)
    print("Parameter change command : {}".format(msg.payload))

def on_next(client, userdata, msg): 
    global nextflag
    nextflag = True

def on_kill(client, userdata, msg): 
    sys.exit(0)

def init(client, userdata, msg): 
    global my_nodes, initflag, my_id_list
    js = json.loads(msg.payload.decode())
    print(js)
    print(my_nodes)
    for my_id in my_id_list:
        my_nodes[my_id].current_state = js[my_id]['state']
        my_nodes[my_id].init_state = js[my_id]['state']
        my_nodes[my_id].pi_neighbours = [x for x in js[my_id]['neighbours']]
        my_nodes[my_id].current_step = 0

        print("Initialization...: {}".format(js[my_id]))
    initflag = True

def on_finish(client, userdata, msg):  # on finish step
    global node_set
    node_id = msg.payload.decode()
    node_set.remove(node_id)
    if len(node_set) == 0:
        nextflag = True
        node_set = {str(x) for x in range(N)}


mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.message_callback_add("start", on_start)
mqttc.message_callback_add("stop", on_stop)
mqttc.message_callback_add("paramet", on_td)
mqttc.message_callback_add("init", init)
mqttc.message_callback_add("next", on_next)
mqttc.message_callback_add("kill", on_kill)
mqttc.message_callback_add("state", on_state)

mqttc.connect(broker_ip)

# for my_id in my_id_list:
#     mqttc.subscribe(str(my_id), 2)
mqttc.subscribe("state", 2)
mqttc.subscribe("start", 2)
mqttc.subscribe("stop", 2)
mqttc.subscribe("paramet", 2)
mqttc.subscribe("init", 2)
mqttc.subscribe("next", 2)
mqttc.subscribe("kill", 2)
mqttc.loop_start()
while not connflag: time.sleep(0.5)
print('Starting...')

while True:
    print('Waiting for initialization...')
    while not initflag: time.sleep(0.5)
    print('Waiting for start...')
    while not startflag: time.sleep(0.5)

    for i in itertools.count():
        for my_node in my_nodes.values():
            my_node.current_step = i
        print('{}) _____________________________________________'.format(i))
        time.sleep(0.2)
        for my_node in my_nodes.values():
            # my_node.broadcast(i)
            mqttc.publish('state', json.dumps({"step": i, "pi_id": my_node.pi_id, 'state': my_node.current_state}))
        while not nextflag: 
            time.sleep(0.1)
        nextflag = False
        time.sleep(0.1)
        for my_node in my_nodes.values():
            print(my_node)
            my_node.transit_to_next_state()


        if stopflag:
            initflag = False
            startflag = False
            nextflag = {my_id: False for my_id in my_id_list}
            print('Simulation is stopped...')
            print('\n\n\n\n\n\n_______________________________________')
            stopflag = False
            break


mqttc.loop_stop()