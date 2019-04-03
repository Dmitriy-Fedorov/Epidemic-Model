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

   


def on_stop(client, userdata, msg): 
    global stopflag
    stopflag = True
    print("Stop command : {}".format(msg.payload))



def on_next(client, userdata, msg): 
    global nextstepflag
    nextstepflag = True

def on_kill(client, userdata, msg): 
    sys.exit(0)


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


mqttc.message_callback_add("nextstep", on_finish_2)



mqttc.subscribe("stop", 2)
mqttc.subscribe("kill", 2)

mqttc.subscribe('nextstep', 2)



while True:
    

    
        time.sleep(0.2)
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


