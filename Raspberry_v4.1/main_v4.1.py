from pi_node import pi_node, PiTransitionDiagram
from defaults import argHandler #Import the default arguments
import paho.mqtt.client as paho
import time
import itertools
import json
import sys
import os

        


stopflag = False
broadcastflag = False
nextstepflag = False
timelimitflag = True






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
    


def on_stop(client, userdata, msg): 
    global stopflag
    stopflag = True
    print("Stop command : {}".format(msg.payload))



def on_next(client, userdata, msg): 
    global nextstepflag
    nextstepflag = True

def on_kill(client, userdata, msg): 
    sys.exit(0)


def on_finish(client, userdata, msg):  # on finish step
    global node_set, N, broadcastflag, node_list
    node_id = msg.payload.decode()
    node_set.discard(node_id)
    # print('on_finish_2', {e for e in node_set if e in node_list})
    print('on_finish_2', node_list)
    if len(node_set) == 0:
        print('Broadcast finished')
        broadcastflag = True
        node_set = {str(x) for x in range(N)}

def on_finish_2(client, userdata, msg):  # on finish step
    global node_set, nextstepflag
    node_id_list = msg.payload.decode()
    node_set = {e for e in node_set if e not in node_id_list}
    print('on_finish_2', node_set)
    if len(node_set) == 0:
        print('Next step')
        nextstepflag = True
        node_set = {str(x) for x in range(N)}





mqttc.message_callback_add("stop", on_stop)
mqttc.message_callback_add("kill", on_kill)
mqttc.message_callback_add("state", on_state)
mqttc.message_callback_add("finish", on_finish)
mqttc.message_callback_add("nextstep", on_finish_2)


mqttc.subscribe("state", 2)
mqttc.subscribe("start", 2)
mqttc.subscribe("stop", 2)
mqttc.subscribe("paramet", 2)
mqttc.subscribe("init", 2)
mqttc.subscribe("kill", 2)
mqttc.subscribe("finish", 2)
mqttc.subscribe('nextstep', 2)



while True:
    print('Waiting for initialization...')
    while not initflag: time.sleep(0.5)
    print('Waiting for start...')
    while not startflag: time.sleep(0.5)
    for my_node in my_nodes.values():
        my_node.current_step = 0

    for i in itertools.count():
        print('{}) _____________________________________________'.format(i))
        time.sleep(0.2)
        for my_node in my_nodes.values():
            # my_node.broadcast(i)
            mqttc.publish('state', json.dumps({"step": i, "pi_id": my_node.pi_id, 'state': my_node.current_state}), 2)
        limit_counter = 0
        while not broadcastflag: 
            time.sleep(0.1)
            limit_counter += 1
            if limit_counter == 100 and timelimitflag:
                print('!!!step time limit ')
                node_set = {str(x) for x in range(N)}
                broadcastflag = True
                break

        broadcastflag = False
        # time.sleep(0.1)
        for my_node in my_nodes.values():
            print(my_node)
            my_node.transit_to_next_state()
            my_node.current_step = i + 1
        mqttc.publish('nextstep', json.dumps(my_id_list), 2)

        limit_counter = 0
        while not nextstepflag:
            time.sleep(0.1)
            limit_counter += 1
            if limit_counter == 100 and timelimitflag:
                print('!!!step time limit ')
                node_set = {str(x) for x in range(N)}
                nextstepflag = True
                break
        nextstepflag = False

        if stopflag:
            initflag = False
            startflag = False
            broadcastflag = False
            nextstepflag = False
            print('Simulation is stopped...')
            print('\n\n\n\n\n\n_______________________________________')
            stopflag = False
            break


