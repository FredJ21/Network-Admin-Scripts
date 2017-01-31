#!/usr/bin/python
# -*- coding:Utf-8 -*-

import sys
import re
from netaddr import IPNetwork, IPAddress

# ---------------------------------------------------------------------------------
file = open('netstat.conf', 'r')

context = ''
m = ''

colR = '\033[1;31m' # Red
colg = '\033[0;32m' # Green
colG = '\033[1;32m' # Green
colY = '\033[1;33m' # Yellow
colB = '\033[1;34m' # Blue
colW = '\033[1;37m' # Write
colD = '\033[0;39m' # Default


# ---------------------------------------------------------------------------------
if len(sys.argv) > 1 :
        IP =  str(sys.argv[1])
else:
        print '\nUsage: '+ str(sys.argv[0]) +' xx.xx.xx.xx\n'
        exit(1)



# ---------------------------------------------------------------------------------
for line in file:

        m = re.search("\[.+@(.+):(.+)\]", line)
        if m :
                context = m.group(1)
                vsys    = m.group(2)
                #print context, vsys


        if context :
                m = re.search("^(\d+.\d+.\d+.\d+) +(\d+.\d+.\d+.\d+) +(\d+.\d+.\d+.\d+) +\w+ +\d+ \d+ +\d+ (.*)", line)
                if m:

                        subnet = m.group(1)
                        gw     = m.group(2)
                        mask   = m.group(3)
                        interface = m.group(4)

                        if IP == 'all':
                                print context +' Vsys '+ vsys +' --> '+ line,

                        elif IPAddress(IP) in IPNetwork(subnet +"/"+ mask):

                                if subnet == "0.0.0.0":
                                        print context +' Vsys '+ vsys +' --> '+ subnet +"/"+ mask +' gw: '+ gw +' if: '+ interface
                                else:
                                        print context +' Vsys '+ vsys +' --> '+ colG + subnet +"/"+ mask +' gw: '+ gw +' if: '+ interface + colD




