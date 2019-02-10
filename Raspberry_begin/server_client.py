#### For Testing ###
from pi_node import pi_node, PiTransitionDiagram
import itertools
# communications
import paho.mqtt.client as paho
import time

host_name = '192.168.0.101'
connflag = False
my_id = 0
my_neighbours = []





def on_connect(client, userdata, flags, rc):
    global connflag
    connflag = True
    #if connection is successful, rc value will be 0
    print("Connection returned result: " + str(rc) )
    print(flags)
    client.subscribe("#" , 1 )   
 
def on_message(client, userdata, msg): 
    print("topic: " + msg.topic)
    print("payload: " + str(msg.payload))
 
def on_message_msgs(client, userdata, msg): 
    print("test topic: "+msg.topic)
    print("payload: "+str(msg.payload))
#def on_log(client, userdata, level, msg):
#    print(msg.topic+" "+str(msg.payload))
 
mqttc = paho.Client()
mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.message_callback_add("test", on_message_msgs)


mqttc.connect(host_name)
mqttc.loop_start()

while not connflag: pass

for i in itertools.count():
    mqttc.publish("test", i)
    time.sleep(2)


mqttc.loop_stop()