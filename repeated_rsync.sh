#!/usr/bin/env bash

while true; do
  rsync -avz /vagrant /home/vagrant/curriculum-network --exclude=.git --exclude=node_modules
  sleep 1
done
