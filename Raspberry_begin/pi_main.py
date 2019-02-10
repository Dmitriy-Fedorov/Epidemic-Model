from pi_node import pi_node, PiTransitionDiagram
import paho.mqtt.client as paho
import time
import itertools

broker_ip = '192.168.0.101'
connflag = False
my_id = 0
my_neighbours = [
    {
        'pi_id': 0,
        'pi_ip': '192.168.0.101'
    },
    {
        'pi_id': 1,
        'pi_ip': '192.168.0.255'
    }]
paramet = {
        'alpha': [0.2, 0.15], # infect rate 
        'mu': [0.04, 0.04], # sleep s 
        'gamma': [0.08, 0.05], # rec rate 
        'lambda': [0.1, 0.12], # sleep I1 
        'kappa': [0.09, 0.11] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
    }
my_td = PiTransitionDiagram(paramet)
mqttc = paho.Client()
my_node = pi_node(my_id, my_neighbours, my_td, mqttc, state='S_a')


def on_connect(client, userdata, flags, rc):
    global connflag
    #if connection is successful, rc value will be 0
    print("Connection returned result: " + str(rc) )
    print(flags)
    connflag = True


def on_message(client, userdata, msg): 
    global my_node
    my_node.handle_msg(msg)
    print("topic: " + msg.topic)
    print("payload: " + str(msg.payload))


mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.connect(broker_ip)
mqttc.loop_start()


for i in itertools.count():
    my_node.broadcast()
    time.sleep(5)
    my_node.transit_to_next_state()


mqttc.loop_stop()