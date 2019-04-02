from node import pi_node, PiTransitionDiagram
from defaults import argHandler #Import the default arguments
from mqtt_handlers import get_ip
import paho.mqtt.client as paho
import time
import itertools
import json
import sys
import os

# --------- initialization parameters ---------
FLAGS = argHandler()
FLAGS.setDefaults()
FLAGS.parseArgs(sys.argv)
FLAGS['node_ip'] = get_ip()
print(os.getcwd())
print(FLAGS)
N = FLAGS['N']
# my_id_list = [FLAGS['id']]   # only one node in a list
my_id_list = list(range(FLAGS['s'], FLAGS['f']))
print(my_id_list)
my_neighbours = []
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
# print([my_node for my_node in my_nodes.values()])
# other inits
node_set_global = {str(x) for x in range(N)}
## --------- MQTT Flags ---------
connflag = False
initflag = False
startflag = False
wait_broadcast_finish_flag = [False for x in range(N)]

todoflag = [False for x in range(N)]



## --------- MQTT Handlers ---------
def on_connect(client, userdata, flags, rc):
    global connflag, FLAGS
    
    #if connection is successful, rc value will be 0
    print(FLAGS['node_ip'], ": Connection returned result: " + str(rc) )
    connflag = True
    client.publish('ip', 'id {}: {}'.format(FLAGS['id'], FLAGS['node_ip']))

def on_disconnect(client, userdata, rc):
	print("Disconnected From Broker")

def on_message(client, userdata, msg): 
    print('not_expexted', msg.payload.decode())

def on_init(client, userdata, msg): 
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

def on_td(client, userdata, msg): 
    global my_nodes
    paramet = json.loads(msg.payload.decode())
    for my_node in my_nodes:
        my_nodes.pi_td = PiTransitionDiagram(paramet)
    print("Parameter change command : {}".format(msg.payload))
    
def on_start(client, userdata, msg): 
    global startflag
    startflag = True
    print("Simulation started: {}".format(msg.payload))

def on_state(client, userdata, msg): 
    global my_nodes
    # print("-t {} | -p {}".format(msg.topic, msg.payload.decode()) )
    try:
        js = json.loads(msg.payload.decode())
        for my_node in my_nodes.values():
            # handle_msg will drop messages that are not intendent for my_node
            my_node.handle_msg(js) 
        # print(js)
    except Exception as e:
        print('on_state error: ', e)

def on_finish_handshake(client, userdata, msg):  # on finish step
    global wait_broadcast_finish_flag, FLAGS
    node_id = int(msg.payload.decode())
    wait_broadcast_finish_flag[node_id] = True
    # print('on_finish_2', {e for e in node_set if e in node_list})
    # print('on_finish_handshake', node_id)

mqttc.on_connect = on_connect
mqttc.on_disconnect = on_disconnect
mqttc.on_message = on_message
mqttc.message_callback_add("paramet", on_td)
mqttc.message_callback_add("init", on_init)
mqttc.message_callback_add("start", on_start)
mqttc.message_callback_add("state", on_state)
mqttc.message_callback_add("finish", on_finish_handshake)




## --------- MQTT Connect ---------
mqttc.will_set('dis', payload='disconnected| id {id}: {node_ip}'.format(**FLAGS), qos=0, retain=False)
mqttc.max_inflight_messages_set(1000)
mqttc.connect(FLAGS['broker_ip'])

## --------- MQTT Subscriptions ---------
mqttc.subscribe("state", 2)
mqttc.subscribe("start", 2)
mqttc.subscribe("init", 2)
mqttc.subscribe("paramet", 2)
mqttc.subscribe("finish", 2)

## --------- MQTT Start process ---------
mqttc.loop_start()
while not connflag: time.sleep(0.5)
print('Starting...')

while True:
    print('Waiting for initialization...')
    while not initflag: time.sleep(0.5)
    print('Waiting for start...')
    while not startflag: time.sleep(0.5)
    for my_node in my_nodes.values():
        my_node.current_step = 0
    
    ## --- Simulation loop
    for i in itertools.count():
        print('{}) _____________________________________________'.format(i))
        # --- broadcast current state --- #
        for my_node in my_nodes.values():  # broadcast current state
            mqttc.publish('state', json.dumps({"step": i, "pi_id": my_node.pi_id, 'state': my_node.current_state}), 2)
        # --- wait until every node has finished communication & transition --- #
        while not all(wait_broadcast_finish_flag): 
            time.sleep(0.1)
        wait_broadcast_finish_flag = [False for x in range(N)]
        # time.sleep(0.5)





## --------- MQTT Closure ---------
mqttc.loop_stop()