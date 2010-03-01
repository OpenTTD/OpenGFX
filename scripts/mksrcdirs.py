#! /usr/bin/env python

import os
import sys
import string

while 1:
	data = sys.stdin.readline()
	if data != '':
		if not os.access(data,os.F_OK):
			sys.stdout.write("Creating "+data)
			os.makedirs(string.strip(data))
	else:
		sys.stdout.flush()
		break
