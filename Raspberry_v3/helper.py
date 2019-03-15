import os

path = "A:/Dropbox/8th/Capstone/Epidemic-Model/Raspberry_v3"
path = "/mnt/2C3AED6A3AED318E/Dropbox/8th/Capstone/Epidemic-Model/Raspberry_v3"

nodes = ['node_2']
files = ['pi_main_v3.py', 'pi_node.py']


for node in nodes:
    for file_ in files:
        os.link("{}/{}".format(path, file_), "{}/{}/{}".format(path, node, file_))  
