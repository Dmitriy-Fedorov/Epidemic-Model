import numpy as np 
import networkx as nx 
from numpy.random import uniform
from random import sample
import pandas as pd
import time 

def calc_R0(G, p):
    adj = nx.adjacency_matrix(G)
    # print(adj.shape)
    # N = adj.shape[0]
    betta = p['betta']
    gamma = p['gamma']
    # I =  np.eye(N, dtype=int)
    # muuuu = mu[0]/(mu[0] + mu[1])
    # R1 = (alpha[0]*adj*muuuu + lambda_[0]*I)/(gamma[0]+lambda_[1])
    # R2 = (alpha[1]*adj*muuuu + kappa[0]*I)/(gamma[1]+kappa[1])
    # R1 = max(np.linalg.eigvals(R1))
    # R2 = max(np.linalg.eigvals(R2))
    R0 = betta/gamma
    return R0


class TransitionDiagram:

    def __init__(self, paramet):
        paramet_example = {
            'betta': 0.1, # infect rate 
            'gamma': 0.1, # rec rate 
        }
        self.status_list = ['S', 'I']
        self.transitions = {
            'S': {
                'I': paramet['betta']
            },
            'I': {
                'S': paramet['gamma']
            }
        }
    
    def get_next_state(self, G, id):
        node = G.node[id]
        state = node['state']
        transition_prob = self.transitions[state]
        if state == 'S': # edge transition
            next_state = state

            for n_id in sample(list(G[id]), len(G[id])):  # neighbor_id
                nstate = G.node[n_id]['state']
                if nstate == 'I':
                    if uniform() < transition_prob['I']:
                        next_state = 'I'
                        break
        
        else:  # no adjacency matrix rerquired, node transition
            nrand = uniform()
            next_state = state  # default next state
            for k, v in transition_prob.items():
                nrand -= v
                if nrand < 0:
                    next_state = k
                    break
        
        node['next_state'] = next_state


class EpidemicGraph:

    def __init__(self, N, radius, paramet, I=1, grid_size=[10,10], net='Geometric Random'):
        self.G = nx.Graph(net=net, paramet=paramet, radius=radius, grid_size=grid_size)
        self.population_size = N
        self.population_history = {
            'S':  [N-I],
            'I':  [I]
        }
        self.grid_size = grid_size
        self.radius = radius
        self.paramet = paramet
        self.trans = TransitionDiagram(paramet)
        self.state_list = ['S', 'I']
        self.create_nodes(N)
        self.init_state(I)
        self.connect_nodes()

    def create_nodes(self, n):
        if self.G.graph['net'] == 'Geometric Random':
            for i in range(n):
                self.G.add_node(i, state='S', 
                                position=uniform(0, self.grid_size, 2))
        elif self.G.graph['net'] == 'Uniform Grid':
            for i in range(n):
                self.G.add_node(i, state='S', 
                                position=np.array([i//self.grid_size[0], i%self.grid_size[1]]))
        else:
            assert False
        
    def connect_nodes(self, verbose=False):
        def dist(pos1,pos2):
            return np.linalg.norm(pos1-pos2)
        for node1 in self.G.nodes(data=True):
            for node2 in self.G.nodes(data=True):
                pos1 = node1[1]['position']
                pos2 = node2[1]['position']
                if node1[0] < node2[0]:
                    distance = dist(pos1,pos2)
                    if distance <= self.radius:
                        self.G.add_edge(node1[0], node2[0] )
                        if verbose:
                            print(f"{node1[0]}<->{node2[0]}: {distance}")
                    else:
                        if verbose:
                            print(f"{node1[0]}<X>{node2[0]}: {distance}")

    def init_state(self, I):
        unlucky_nodes = sample(range(self.population_size), I)
        for node_id in unlucky_nodes:
            self.G.node[node_id]['state'] = 'I'
                
    def load_csv(self, csv, I0):
        adj = pd.read_csv(csv, header=None)
        self.G = nx.from_numpy_matrix(adj.values)
        for node_id in self.G.nodes:
            self.G.node[node_id]['state'] = 'S'
        self.init_state(I0)

        

    def step(self):
        population_count = {
            'S':  0,
            'I':  0
        }
        for i in range(self.population_size):
            self.trans.get_next_state(self.G, i)
        for i in range(self.population_size):
            state = self.G.node[i]['next_state']
            self.G.node[i]['state'] = state
            population_count[state] += 1
        for k,v in population_count.items():
            self.population_history[k].append(v)

        assert sum(population_count.values()) == self.population_size
        return population_count

    def run(self, nsteps):
        l = []
        assert len(self.G.adj) == self.population_size
        for n in range(nsteps):
            l.append(time.time())
            self.step()
        l.append(time.time())
        return l

    def hist2pandas(self):
        return pd.DataFrame(self.population_history)

