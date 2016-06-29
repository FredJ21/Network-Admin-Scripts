#!/usr/bin/python
# -*- coding:Utf-8 -*-

import socket
import os

my_conf = "host.ini"



CO_V = "\033[1;32m"; #vert
CO_R = "\033[1;31m"; #rouge
CO_O = "\033[1;33m"; #orange
CO_B = "\033[1;34m"; #bleu
CO_N = "\033[0;39m"; #normal


fo = open(my_conf, "r")
lines = fo.readlines()
fo.close


for i in range(	len(lines)):

	lines[i] = lines[i].rstrip()

	if ( lines[i][0] == '#' ):
		print CO_B + lines[i] + CO_N

	else:

		IP   = lines[i].split(';')[0]
		PORT = lines[i].split(';')[1]
		DESC = lines[i].split(';')[2]

		if ( PORT == 'icmp' ): 		#	Test Ping

			print IP +"\tICMP\t",
			
			response = os.system("ping -c 1 -W 1 " + IP +" >/dev/null")

			if response == 0:
   				print CO_V +" OK "+ CO_N,
			else:
   				print CO_R +" HS "+ CO_N,

			print "\t", DESC

		else:				#	Test TCP
			print IP +"\ttcp:"+ PORT +"\t",
	
			sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			sock.settimeout(1)
			result = sock.connect_ex((IP , int(PORT) ))
			if result == 0:
   				print CO_V +" OPEN "+ CO_N,
			else:
   				print CO_R +" CLOSE"+ CO_N,

			print "\t", DESC

