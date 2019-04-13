from node import pi_node, PiTransitionDiagram
from defaults import argHandler #Import the default arguments
from helpers import get_ip
import numpy as np
import paho.mqtt.client as paho
from random import sample
import itertools
import random
import time
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
if FLAGS['id'] < 0:
    my_id_list = list(range(FLAGS['s'], FLAGS['f']))
else:
    my_id_list = [FLAGS['id']]   # only one node in a list
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
my_qos = 2

## --------- MQTT Flags ---------
connflag = False
initflag = False
startflag = False
wait_broadcast_finish_flag = [False for x in range(N)]
wait_transition_finish_flag = [False for x in range(N)]



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
    for my_node in my_nodes.values():
        my_node.pi_td = PiTransitionDiagram(paramet)
    print("Parameter change command : {}".format(msg.payload))
    
def on_start(client, userdata, msg): 
    global startflag
    startflag = True
    print("Simulation started: {}".format(msg.payload))

def on_state(client, userdata, msg): 
    global my_nodes, my_qos
    # print("-t {} | -p {}".format(msg.topic, msg.payload.decode()) )
    queue = []
    try:
        js = json.loads(msg.payload.decode())
        for my_node in my_nodes.values():
            # handle_msg will drop messages that are not intendent for my_node
            response = my_node.handle_msg(js) 
            if response is not None:
                queue.append(response)
        # print(js)
        if len(queue) > 0:
            time.sleep(1)
            for msg in queue:
                print('republish', msg)
                client.publish('state', json.dumps(msg), my_qos)
    except Exception as e:
        print('on_state error: ', e)

def on_finish_handshake(client, userdata, msg):  # on finish step
    global wait_broadcast_finish_flag, FLAGS
    node_id = int(msg.payload.decode())
    wait_broadcast_finish_flag[node_id] = True
    # print('on_finish_2', {e for e in node_set if e in node_list})
    # print('on_finish_handshake', node_id)

def on_finish_transition(client, userdata, msg):  # on finish step
    global wait_transition_finish_flag, FLAGS
    node_id = int(msg.payload.decode())
    wait_transition_finish_flag[node_id] = True
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
mqttc.message_callback_add("finish_trans", on_finish_transition)




## --------- MQTT Connect ---------
mqttc.will_set('dis', payload='disconnected| id {id}: {node_ip}'.format(**FLAGS), qos=2, retain=False)
# mqttc.max_inflight_messages_set(0)
# mqttc.max_queued_messages(0)
# mqttc.max_inflight_messages(0)
mqttc.connect(FLAGS['broker_ip'])

## --------- MQTT Subscriptions ---------
mqttc.subscribe("state", my_qos)
mqttc.subscribe("start", my_qos)
mqttc.subscribe("init", my_qos)
mqttc.subscribe("paramet", my_qos)
mqttc.subscribe("finish", my_qos)
mqttc.subscribe("finish_trans", my_qos)

## --------- MQTT Start process ---------
mqttc.loop_start()
while not connflag: time.sleep(0.5)
print('Starting...')


## --------- helper functions ---------
def wait_until_all_true(true_list, delay=0.1):
    while not all(true_list): 
        time.sleep(delay)

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
        for my_node in sample(list(my_nodes.values()), len(my_nodes.values())):  # broadcast current state
            my_node.current_step = i
            time.sleep(random.random()*FLAGS['delay_koef'])
            mqttc.publish('state', json.dumps({"step": i, "pi_id": my_node.pi_id, 'state': my_node.current_state}), my_qos)
        # --- wait until every node has finished communication --- #
        wait_until_all_true(wait_broadcast_finish_flag)
        time.sleep(FLAGS['delay'])
        wait_broadcast_finish_flag = [False for x in range(N)]
        print('## Finish broadcast')
        for my_node in sample(list(my_nodes.values()), len(my_nodes.values())):  # broadcast current state
            time.sleep(random.random()*FLAGS['delay_koef'])
            my_node.transit_to_next_state()
        
        # --- wait until every node has finished transition --- #
        wait_until_all_true(wait_transition_finish_flag)
        time.sleep(FLAGS['delay'])
        wait_transition_finish_flag = [False for x in range(N)]
        print('## Finish transition')





## --------- MQTT Closure ---------
mqttc.loop_stop()