#!/usr/bin/env bash

apt-get update
apt-get install -y nodejs nodejs-legacy npm mongodb-server
npm install -g mongosrv LiveScript coffee-script node-dev

cd /home/vagrant
if [ ! -d "curriculum-network" ]; then
  su vagrant -c 'ln -s /vagrant curriculum-network'
  echo "cd curriculum-network; ./runserver" > runserver
  chmod +x runserver
  chown vagrant:vagrant runserver
  cd curriculum-network
  if [ -d "node_modules" ]; then
    rm -r node_modules
  fi
  su vagrant -c 'npm install'
fi