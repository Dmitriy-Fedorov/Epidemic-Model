class argHandler(dict):
    #A super duper fancy custom made CLI argument handler!!
    __getattr__ = dict.get
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__
    _descriptions = {'help, --h, -h': 'show this super helpful message and exit'}
    
    def setDefaults(self):
        self.define('broker_ip', '10.101.21.2', 'broker ip adress')
        # self.define('broker_ip', 'localhost', 'broker ip adress')
        self.define('node_ip', 'localhost', 'node ip adress')
        self.define('s', 0, 'super node id start range')
        self.define('f', 10, 'super node id finish range')
        self.define('stotal', 1, 'total number of super nodes')
        self.define('N', 10, 'total number of virtual nodes')
        self.define('id', -1, 'define node ID')
        self.define('delay_koef', 10, 'random delay multiplier koef')

    def setDefaultsDeploy(self):
        # self.define('broker_ip', '10.101.21.2', 'broker ip adress')
        self.setDefaults()
        self.define('step', 1, 'represents number of virtual nodes per process')
       



    def define(self, argName, default, description):
        self[argName] = default
        self._descriptions[argName] = description
    
    def help(self):
        print('Example usage: flow --imgdir sample_img/ --model cfg/yolo.cfg --load bin/yolo.weights')
        print('')
        print('Arguments:')
        spacing = max([len(i) for i in self._descriptions.keys()]) + 2
        for item in self._descriptions:
            currentSpacing = spacing - len(item)
            print('  --' + item + (' ' * currentSpacing) + self._descriptions[item])
        print('')
        exit()

    def parseArgs(self, args):
        print('')
        i = 1
        while i < len(args):
            if args[i] == '-h' or args[i] == '--h' or args[i] == '--help':
                self.help() #Time for some self help! :)
            if len(args[i]) < 2:
                print('ERROR - Invalid argument: ' + args[i])
                print('Try running flow --help')
                exit()
            argumentName = args[i][2:]
            if isinstance(self.get(argumentName), bool):
                if not (i + 1) >= len(args) and (args[i + 1].lower() != 'false' and args[i + 1].lower() != 'true') and not args[i + 1].startswith('--'):
                    print('ERROR - Expected boolean value (or no value) following argument: ' + args[i])
                    print('Try running flow --help')
                    exit()
                elif not (i + 1) >= len(args) and (args[i + 1].lower() == 'false' or args[i + 1].lower() == 'true'):
                    self[argumentName] = (args[i + 1].lower() == 'true')
                    i += 1
                else:
                    self[argumentName] = True
            elif args[i].startswith('--') and not (i + 1) >= len(args) and not args[i + 1].startswith('--') and argumentName in self:
                if isinstance(self[argumentName], float):
                    try:
                        args[i + 1] = float(args[i + 1])
                    except:
                        print('ERROR - Expected float for argument: ' + args[i])
                        print('Try running flow --help')
                        exit()
                elif isinstance(self[argumentName], int):
                    try:
                        args[i + 1] = int(args[i + 1])
                    except:
                        print('ERROR - Expected int for argument: ' + args[i])
                        print('Try running flow --help')
                        exit()
                self[argumentName] = args[i + 1]
                i += 1
            else:
                print('ERROR - Invalid argument: ' + args[i])
                print('Try running flow --help')
                exit()
            i += 1
