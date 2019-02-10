import numpy as np 
from numpy.random import uniform
from random import sample
import json



class PiTransitionDiagram:

    def __init__(self, paramet):
        self.status_list = ['S_a','S_s','I1_a','I1_s','I2_a','I2_s']
        self.transitions = {
            'S_a': {
                'S_s': paramet['mu'][1], #
                'I1_a': paramet['alpha'][0], #
                'I2_a': paramet['alpha'][1] #
            },
            'S_s': {
                'S_a': paramet['mu'][0] #
            },
            'I1_a': {
                'S_a': paramet['gamma'][0], #
                'I1_s': paramet['lambda'][1] #
            },
            'I1_s': {
                'I1_a': paramet['lambda'][0] # 
            },
            'I2_a': {
                'S_a': paramet['gamma'][1],  #
                'I2_s': paramet['kappa'][1]  #
            },
            'I2_s':{
                'I2_a': paramet['kappa'][0]  #
            } 
        }
    

    def roll_infection_dice(self, nstate): 
            if nstate == 'I1_a':
                if uniform() < transition_prob['I1_a']:
                    next_state = 'I1_a'
                    return next_state
            elif nstate == 'I2_a':
                if uniform() < transition_prob['I2_a']:
                    next_state = 'I2_a'
                    return next_state
            
    def roll_end_state(self, state):
        transition_prob = self.transitions[state]

        if state == 'S_a': # edge transition
            next_state = state
            if uniform() < transition_prob['S_s']:
                next_state = 'S_s'
            
        
        else:  # no adjacency matrix rerquired, node transition
            nrand = uniform()
            next_state = state  # default next state
            for k, v in transition_prob.items():
                nrand -= v
                if nrand < 0:
                    next_state = k
                    break
        
        return next_state



class pi_node:

    def __init__(self, pi_id, pi_neighbours, pi_td, mqttc, state='S_a'):  # pi_td: PiTransitionDiagram
        self.pi_id = pi_id
        self.pi_neighbours = pi_neighbours
        self.pi_td = pi_td
        self.current_state = state
        self.next_state = None
        self.init_state = state
        self.n_neighbours = len(pi_neighbours)
        self.flag_counter = 0
        self.flag_end_round = False
        self.mqttc = mqttc
        
        # publish to neighbours

    
    def handle_msg(self, msg):
        nstate = msg['state']
        if self.current_state == 'S_a':
            if self.flag_counter < self.n_neighbours and not self.flag_end_round:  # ensure communication with every neighbour
                next_state = self.pi_td.roll_infection_dice(nstate)  
                if next_state != self.current_state:  # if it is infected communication round is finished
                    self.next_state = next_state
                    self.flag_end_round = True
            
            self.flag_counter += 1
            if self.flag_counter == self.n_neighbours and not self.flag_end_round:  # if it is last neighbour node has probability to go to sleep
                next_state = self.pi_td.roll_end_state(self.current_state)
                self.next_state = next_state
                self.flag_end_round = True
        else:
            if not self.flag_end_round:  # if it 
                next_state = self.pi_td.roll_end_state(self.current_state)
                self.next_state = next_state
                self.flag_end_round = True
                self.flag_counter = self.n_neighbours

    def transit_to_next_state(self):
        self.flag_end_round = False
        self.flag_counter = 0
        self.current_state = self.next_state
        # assert self.flag_counter == self.n_neighbours

    def broadcast(self):
        msg = {
                'pi_id': self.pi_id,
                'state': self.current_state
            }
        for node in self.pi_neighbours:  # broadcast current state
            topic = node['pi_id'] 
            self.mqttc.publish(topic, json.dumps(msg)) 


pi_neighbours = [
    {
        'pi_id': 0,
        'pi_ip': '192.168.0.101'
    },
    {
        'pi_id': 1,
        'pi_ip': '192.168.0.255'
    }]