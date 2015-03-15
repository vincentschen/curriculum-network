#!/usr/bin/env bash

while true; do
  rsync -avz /vagrant/curriculum-network /home/vagrant/curriculum-network
  sleep 1
done
