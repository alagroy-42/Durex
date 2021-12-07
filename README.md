# Durex

A basic trojan installing a daemon that opens a server allowing a TCP connection on a root shell. It has been made for a 64-bits Debian 11 machine fbut it shoul work on most of popular 64-bits Linux distros

## Disclaimer

This project is an educational project, I cannot be held responsible for any illegal use with this program.

## Use

```
make
sudo ./Durex
```

## Description

The Durex program, once executed with root rights will install another program in `/usr/bin`, also named `Durex`, it will also launch it in background and set up the `/etc/rc.local` file so that it can be launched as reboot.

### The payload 

The payload is a RAT tool, it will offer 3 simulteanous connections on port 4242 of the machine. It will need a password (default is `rootroot4242`). Once connected, you can launch a remote root shell with the shell command, the port on which the shell listens to will be displayed.
The payload will be "pre-compiled" by `./scripts/tiny.py` which will make it super lite (around 1,8 KB) by manually writing the ELF headers and removing all the useless informations.

### The trojan

The trojan contains a URL-encoded string that once decoded is the executable xored with a 32-bits key. The key is the last 32-bits part of the payload. Once decoded, the `.text` part of the payload will be re-encrypted by the program. 
The encryption algorithm is also an xored-base custom algo but on this one each byte of the key is being increased by 42 each time we reuse the key, so that it is different for each round. A decryption routine is inserted in the program and the entrypoint is being changed to point on it.
The program will be then stored, executed and we will write on `/etc/rc.local` to make it persistent.

## Ressources
[Tuto to make really tiny ELF files](https://www.muppetlabs.com/~breadbox/software/tiny/teensy.html)

