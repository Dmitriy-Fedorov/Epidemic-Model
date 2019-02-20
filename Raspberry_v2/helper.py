import os

path = "A:/Dropbox/8th/Capstone/Epidemic-Model/Raspberry_v2"
path = "/mnt/2C3AED6A3AED318E/Dropbox/8th/Capstone/Epidemic-Model/Raspberry_v2"

nodes = ['node_1','node_2', 'node_3', 'node_4']
files = ['pi_main.py', 'pi_node.py', 'pi_main_2.py']


for node in nodes:
    for file_ in files:
        os.link(f"{path}/{file_}", f"{path}/{node}/{file_}")  
