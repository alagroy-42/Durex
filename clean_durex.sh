#!/bin/bash

sudo rm -f /bin/Durex
sudo rm -f /etc/rc.local
sudo kill -9 `pidof '[jbd2/sda0-8]'`
sudo kill -9 `pidof '[jbd2/sda0-6]'`
sudo kill -9 `pidof '[jbd2/sda0-7]'`