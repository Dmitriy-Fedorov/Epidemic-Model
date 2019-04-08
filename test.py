import numpy as np
import sys
import time

# print(5, file=sys.stdout,flush=True)
# print(6, file=sys.stdout)


 
# for i in range(10):
#     # print(i,file=sys.stdout, flush="True")
#     sys.stdout.write('%d\r' % i)
#     time.sleep(0.1)

i = {1,2,3,8,9}

sys.stdout.write('%s\r' % i)
sys.stdout.flush()
i.discard(1)
sys.stdout.write('%.100s\r' % i)
i.discard(9)
sys.stdout.write('%.100s\r\n' % i)

print(5)
print('asd')



# rsync -avz -e 'ssh' /mnt/2C3AED6A3AED318E/Dropbox/8th/Capstone/Epidemic-Model/Raspberry_v4.1 pi@10.101.47.225: /home/pi/6pi
