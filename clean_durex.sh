#!/bin/bash

sudo rm -f /bin/Durex
sudo rm -f /etc/rc.local
sudo kill -9 `pidof '[jbd2/sda1-5]'`
sudo kill -9 `pidof '[jbd2/sda1-6]'`
sudo kill -9 `pidof '[jbd2/sda1-7]'`
