#!/usr/bin/env python3
import re

regex = re.compile('^(.*?)\s?=\s?(.*?)$')
data = ''

with open('server.properties', 'r') as fh:
    lines = fh.readlines()
    for line in lines:
        match = regex.search(line)
        if not re.match('^#.*|^\n|^/r', line):
            print(match)
            data += (match.group(1) + "={{ getv(\"/minecraft/" + match.group(1).lower().replace('-', '/') + "\", \"" + match.group(2) + "\") }}" + "\n")
        else:
            data += line

with open('server.properties.new', 'w') as fh:
    fh.write(data)
    print(data)

