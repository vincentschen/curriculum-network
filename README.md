# curriculum visualization

## Demo

A live demo of this code is at http://csnet.herokuapp.com

Hovering over a node will highlight the associated nodes.

blue = children

green = depends

purple = suggests

## Curriculum Network

The curriculum network is located in [graph.yaml](https://github.com/gkovacs/curriculum-network/blob/master/graph.yaml)

Each node (representing a topic) can be associated with a list of children, depends, and suggests

## Prerequisites, setup, and running

Make sure you have mongodb installed. On OSX, you can install it via (you'll need [homebrew](http://brew.sh/) installed):

    brew install mongodb

Now let's install some tools with npm (you'll need [nodejs](https://nodejs.org/) installed):

    npm install -g mongosrv LiveScript node-dev

git clone this repo:

    git clone https://github.com/gkovacs/curriculum-network

cd to the directory and install the npm modules it depends on:

   cd curriculum-network
   npm install

You can start the server by running (this will start a mongodb server locally, automatically compile changed ls files, and start the node server on port 5000):

    ./runserver

You can then visit http://localhost:5000 to see the page in action

## Source Layout

css files are in the css directory

js files are in the js directory

Some js files are generated from [LiveScript](http://livescript.net) files (.ls extension). The ./runserver command will automatically watch them and compile them to js files as they are changed.
