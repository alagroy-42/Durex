#!/usr/bin/python3

import os
import urllib.parse

def obfuscate_xor(tiny):
    len_key = 32
    xored = ''
    i = 0
    key = bytes(os.urandom(len_key))
    for byte in tiny:
        if i == len_key:
            i = 0
        xored += chr(byte ^ key[i])
        i += 1
    for i in range(len_key):
        xored += chr(key[i])
    return xored

def make_payload_file(payload):
    return 'char *payload = "' + payload + '";'

if __name__ == '__main__':
    tiny_file = './tiny_service'
    output_file = './srcs/payload.c'
    filestream = open(tiny_file, 'rb')
    tiny = filestream.read()
    filestream.close()
    xored = obfuscate_xor(tiny)
    payload = urllib.parse.quote(xored)
    filestream = open(output_file, 'w')
    filestream.write(make_payload_file(payload))
    filestream.close()