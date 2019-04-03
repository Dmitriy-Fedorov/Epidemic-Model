import numpy as np 
import networkx as nx 
from numpy.random import uniform
from random import sample
import pandas as pd


def calc_R0(G, p):
    adj = nx.adjacency_matrix(G)
    # print(adj.shape)
    N = adj.shape[0]
    mu = p['mu']
    alpha = p['alpha']
    gamma = p['gamma']
    lambda_ = p['lambda']
    kappa = p['kappa']
    I =  np.eye(N, dtype=int)
    muuuu = mu[0]/(mu[0] + mu[1])
    R1 = (alpha[0]*adj*muuuu + lambda_[0]*I)/(gamma[0]+lambda_[1])
    R2 = (alpha[1]*adj*muuuu + kappa[0]*I)/(gamma[1]+kappa[1])
    R1 = max(np.linalg.eigvals(R1))
    R2 = max(np.linalg.eigvals(R2))
    return R1, R2


class TransitionDiagram:

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
    
    def get_next_state(self, G, id):
        node = G.node[id]
        state = node['state']
        transition_prob = self.transitions[state]
        if state == 'S_a_': # edge transition
            I1 = 0
            I2 = 0
            # count number of infected neighbors
            for n_id in G[id]:  # neighbor_id
                nstate = G.node[n_id]['state']
                if nstate == 'I1_a':
                    I1 += 1
                elif nstate == 'I2_a':
                    I2 += 1
            I1p = 1 - (1-transition_prob['I1_a'])**I1  # p_total - (p_not_infected)^number_of_encounters 
            I2p = 1 - (1-transition_prob['I2_a'])**I2  # p_total - (p_not_infected)^number_of_encounters 
            next_state = state
            if I1 != 0:
                if uniform() < I1p: # infected by I1
                    next_state = 'I1_a'
                    if uniform() < I2p: # infected by I2
                        # conflicting situation
                        # conflict resolution
                        boundary = I1/(I1+I2)
                        if uniform() > boundary: 
                            next_state = 'I2_a'
            elif I2 != 0:
                if uniform() < I2p:
                    next_state = 'I2_a'
            elif uniform() < transition_prob['S_s']:
                next_state = 'S_s'

        elif state == 'S_a': # edge transition
            next_state = state

            for n_id in sample(list(G[id]), len(G[id])):  # neighbor_id
                nstate = G.node[n_id]['state']
                if nstate == 'I1_a':
                    if uniform() < transition_prob['I1_a']:
                        next_state = 'I1_a'
                        break
                elif nstate == 'I2_a':
                    if uniform() < transition_prob['I2_a']:
                        next_state = 'I2_a'
                        break
            if uniform() < transition_prob['S_s'] and next_state=='S_a':
                next_state = 'S_s'
            
        
        elif state == 'S_a_2': # edge transition
            I1 = 0
            I2 = 0
            total = len(G[id]) + 1
            # count number of infected neighbors
            for n_id in G[id]:  # neighbor_id
                nstate = G.node[n_id]['state']
                if nstate == 'I1_a':
                    I1 += 1
                elif nstate == 'I2_a':
                    I2 += 1
            I1p = transition_prob['I1_a']*I1 #/total
            I2p = transition_prob['I2_a']*I2 #/total  # p_total - (p_not_infected)^number_of_encounters 
            # assert I1p + I2p + transition_prob['S_s'] < 1
            next_state = state # default next state/ ie current
            S_a_transit = {
                'S_s': transition_prob['S_s'], #
                'I1_a': I1p, #
                'I2_a': I2p #
            }
            nrand = uniform()
            for k, v in S_a_transit.items():
                nrand -= v
                if nrand < 0:
                    next_state = k
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

    def __init__(self, N, radius, paramet, I1_a=1, I2_a=1, grid_size=[10,10], net='Geometric Random', create=True):
        self.G = nx.Graph(net=net, paramet=paramet, radius=radius, grid_size=grid_size)
        self.population_size = N
        self.population_history = {
            'S_a':  [N-I1_a-I2_a],
            'S_s':  [0],
            'I1_a': [I1_a],
            'I1_s': [0],
            'I2_a': [I2_a],
            'I2_s': [0]
        }
        self.grid_size = grid_size
        self.radius = radius
        self.paramet = paramet
        self.trans = TransitionDiagram(paramet)
        self.state_list = ['S_a','S_s','I1_a','I1_s','I2_a','I2_s']
        if create:
            self.create_nodes(N)
            self.init_state(I1_a, I2_a)
            self.connect_nodes()

    @classmethod
    def load(cls, N, radius, paramet, I1_a=1, I2_a=1, grid_size=[30,30], net='Geometric Random'):
        def factory(r=1.5):
            G = nx.from_numpy_matrix(pd.read_csv(f'adj_{r}.csv', header=None).values)
            pos = pd.read_csv(f'pos_{r}.csv', header=None).values.T
            pos_dict = {}
            for i, xy in enumerate(pos):
                pos_dict[i] = xy
            nx.set_node_attributes(G, pos_dict, 'position')
            
            inf = pd.read_csv(f'inf_{r}.csv', header=None).values[0]
            inf_1 = inf[0:len(inf)//2]
            inf_2 = inf[len(inf)//2:]
            # print(len(inf_1), len(inf_2))
            for node_id in G.nodes():
                if node_id in inf_1:
                    G.node[node_id]['state'] = 'I1_a'
                    G.node[node_id]['init_state'] = 'I1_a'
                    # print(node_id, 'I1_a')
                elif node_id in inf_2:
                    G.node[node_id]['state'] = 'I2_a'
                    G.node[node_id]['init_state'] = 'I2_a'
                    # print(node_id, 'I2_a')
                else:
                    G.node[node_id]['state'] = 'S_a'
                    G.node[node_id]['init_state'] = 'S_a'
            return G
        
        self = cls(N, radius, paramet, I1_a, I2_a, grid_size, net, False)
        self.G = factory(radius)
        return self

    def reset(self):
        temp = {}
        for k,v in self.population_history.items():
            temp[k] = [v[0]]
        self.population_history = temp
        for i in range(self.population_size):
            state = self.G.node[i]['init_state']
            self.G.node[i]['state'] = state


    def create_nodes(self, n):
        if self.G.graph['net'] == 'Geometric Random':
            for i in range(n):
                self.G.add_node(i, state='S_a', init_state='S_a',
                                position=uniform(0, self.grid_size, 2))
        elif self.G.graph['net'] == 'Uniform Grid':
            for i in range(n):
                self.G.add_node(i, state='S_a', init_state='S_a',
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

    def init_state(self, I1_a, I2_a):
        unlucky_nodes = sample(range(self.population_size), I1_a + I2_a)
        I1 = unlucky_nodes[:I1_a]
        I2 = unlucky_nodes[I1_a:]
        for node_id in I1:
            self.G.node[node_id]['state'] = 'I1_a'
            self.G.node[node_id]['init_state'] = 'I1_a'
        for node_id in I2:
            self.G.node[node_id]['state'] = 'I2_a'
            self.G.node[node_id]['init_state'] = 'I2_a'
                
    def load_csv(self, csv, I1_a, I2_a):
        adj = pd.read_csv(csv, header=None)
        self.G = nx.from_numpy_matrix(adj.values)
        for node_id in self.G.nodes:
            self.G.node[node_id]['state'] = 'S_a'
        self.init_state(I1_a, I2_a)
        
    def step(self):
        population_count = {
            'S_a':  0,
            'S_s':  0,
            'I1_a': 0,
            'I1_s': 0,
            'I2_a': 0,
            'I2_s': 0
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
        self.reset()
        for _ in range(nsteps):
            self.step()

    def hist2pandas(self):
        return pd.DataFrame(self.population_history)

if __name__ == "__main__":
    paramet = {
        'alpha': [0.03, 0.06], # infect rate 
        'mu': [0.14, 0.14], # sleep s 
        'gamma': [0.35, 0.47], # rec rate 
        'lambda': [0.05, 0.32], # sleep I1 
        'kappa': [0.04, 0.31] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
    }
    paramet = {  # R1 = 1.4047    R2 = 0.7331
        'alpha': [0.05, 0.03], # infect rate 
        'mu': [0.14, 0.14], # sleep s 
        'gamma': [0.35, 0.47], # rec rate 
        'lambda': [0.05, 0.32], # sleep I1 
        'kappa': [0.04, 0.31] # sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
    }
    