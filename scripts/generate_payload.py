#!/usr/bin/python3

import os
import urllib.parse

def obfuscate_xor(tiny):
    len_key = 32
    xored = ''
    key = os.urandom(len_key)
    for i, byte in enumerate(tiny):
        xored += chr(byte ^ key[i % 32])
    for i in range(len_key):
        xored += chr(key[i])
    return xored

def make_payload_file(payload):
    return 'char *g_payload = "' + payload + '";\n'

if __name__ == '__main__':
    tiny_file = './tiny_service'
    output_file = './srcs/payload.c'
    filestream = open(tiny_file, 'rb')
    tiny = filestream.read()
    filestream.close()
    xored = obfuscate_xor(tiny)
    payload = urllib.parse.quote(xored, encoding='cp1252', errors='backslashreplace').replace('%5Cx', '%')
    filestream = open(output_file, 'w')
    filestream.write(make_payload_file(payload))
    filestream.close()