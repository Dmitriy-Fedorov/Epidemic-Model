from pi_node import pi_node, PiTransitionDiagram
import paho.mqtt.client as paho
import time
import itertools
import json
from pprint import pprint


# broker_ip = '192.168.0.104'
broker_ip = 'localhost'
connflag = False
startflag = False
initflag = False

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
        'alpha': [0.2, 0.15], # infect rate 
        'mu': [0.3, 0.3], # sleep s 
        'gamma': [0.3, 0.3], # rec rate 
        'lambda': [0.1, 0.1], # sleep I1 
        'kappa': [0.2, 0.2] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
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
    print("-t {} | -p {}".format(msg.topic, msg.payload.decode()) )
    try:
        js = json.loads(msg.payload)
        my_node.handle_msg(js)
        # print(js)
    except Exception as e:
        print('Error: ', e)
    
def on_start(client, userdata, msg): 
    global startflag
    startflag = True
    print("Simulation started: {}".format(msg.payload))

def init(client, userdata, msg): 
    global my_node, initflag
    js = json.loads(msg.payload)
    my_id = my_node.pi_id

    my_node.current_state = js[my_id]['state']
    my_node.init_state = js[my_id]['state']
    my_node.pi_neighbours = [{"pi_id": x} for x in js[my_id]['neighbours']]

    print("Initialization...: {}".format(js[my_id]))
    initflag = True

mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.message_callback_add("start", on_start)
mqttc.message_callback_add("init", init)

mqttc.connect(broker_ip)
mqttc.subscribe(str(my_id), 1)
mqttc.subscribe("start", 1)
mqttc.subscribe("init", 1)
mqttc.loop_start()
while not connflag: pass

print('Starting...')
print('Waiting for initialization...')
while not initflag: pass
print('Waiting for start...')
while not startflag: pass

for i in itertools.count():

    print('{}) _____________________________________________'.format(i))
    my_node.broadcast()
    mqttc.publish('state', json.dumps({"id": my_id, 'state': my_node.current_state}))
    time.sleep(4)
    print(my_node)
    time.sleep(1)
    my_node.transit_to_next_state()
    
    

mqttc.loop_stop()