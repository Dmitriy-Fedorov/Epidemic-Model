from pi_node import pi_node, PiTransitionDiagram
import paho.mqtt.client as paho
import time
import itertools
import json
from pprint import pprint


# broker_ip = '192.168.0.104'
# broker_ip = 'localhost'
broker_ip = '10.1.199.251'

connflag = False
startflag = False
initflag = False
stopflag = False
nextflag = False

with open('node_id.json') as f:
    data = json.load(f)
my_id = data['id']

my_neighbours = [
    {
        'pi_id': '0',
        'pi_ip': '192.168.0.101'
    }]
# my_neighbours = None
paramet = {
        'alpha': [0.5, 0.5], # infect rate 
        'mu': [0.5, 0.5], # sleep s 
        'gamma': [0.1, 0.1], # rec rate 
        'lambda': [0.7, 0.2], # sleep I1 
        'kappa': [0.7, 0.2] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
    }

my_td = PiTransitionDiagram(paramet)
mqttc = paho.Client()

my_node = pi_node(my_id, my_neighbours, my_td, mqttc, state='S_a')


def on_connect(client, userdata, flags, rc):
    global connflag
    #if connection is successful, rc value will be 0
    print("Connection returned result: " + str(rc) )
    # print(flags)
    connflag = True

def on_message(client, userdata, msg): 
    global my_node
    # print("-t {} | -p {}".format(msg.topic, msg.payload.decode()) )
    try:
        js = json.loads(msg.payload.decode())
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
    global my_node
    paramet = json.loads(msg.payload.decode())
    my_node.pi_td = PiTransitionDiagram(paramet)
    print("Parameter change command : {}".format(msg.payload))

def on_next(client, userdata, msg): 
    global nextflag
    nextflag = True

def init(client, userdata, msg): 
    global my_node, initflag
    js = json.loads(msg.payload.decode())
    my_id = my_node.pi_id

    my_node.current_state = js[my_id]['state']
    my_node.init_state = js[my_id]['state']
    my_node.pi_neighbours = [{"pi_id": x} for x in js[my_id]['neighbours']]
    my_node.current_step = 0

    print("Initialization...: {}".format(js[my_id]))
    initflag = True

mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.message_callback_add("start", on_start)
mqttc.message_callback_add("stop", on_stop)
mqttc.message_callback_add("paramet", on_td)
mqttc.message_callback_add("init", init)
mqttc.message_callback_add("next", on_next)

mqttc.connect(broker_ip)
mqttc.subscribe(str(my_id), 2)
mqttc.subscribe("start", 2)
mqttc.subscribe("stop", 2)
mqttc.subscribe("paramet", 2)
mqttc.subscribe("init", 2)
mqttc.subscribe("next", 2)
mqttc.loop_start()
while not connflag: time.sleep(0.5)
print('Starting...')

while True:
    print('Waiting for initialization...')
    while not initflag: time.sleep(0.5)
    print('Waiting for start...')
    while not startflag: time.sleep(0.5)

    for i in itertools.count():
        my_node.current_step = i
        print('{}) _____________________________________________'.format(i))
        time.sleep(0.2)
        my_node.broadcast(i)
        mqttc.publish('state', json.dumps({"step": i, "id": my_node.pi_id, 'state': my_node.current_state}))
        while not nextflag: 
            time.sleep(0.1)
        nextflag = False
        print(my_node)
        time.sleep(0.1)
        my_node.transit_to_next_state()
        

        if stopflag:
            initflag = False
            startflag = False
            print('Simulation is stopped...')
            print('\n\n\n\n\n\n_______________________________________')
            stopflag = False
            break
    
    

mqttc.loop_stop()