# curriculum visualization

## Demo

A live demo of this code is at http://csnet.herokuapp.com

Hovering over a node will highlight the associated nodes.

* blue = depends
* orange = parents

## Curriculum Network

The curriculum network is located in [graph.yaml](https://github.com/gkovacs/curriculum-network/blob/master/graph.yaml)

Each node (representing a topic) can be associated with a list of depends and parents.

## Prerequisites, setup, and running

First git clone this repo (never used git before? [see here](https://help.github.com/articles/set-up-git/)) and cd to it:

    git clone https://github.com/gkovacs/curriculum-network
    cd curriculum-network

Now register for the [Bing Search API](https://datamarket.azure.com/dataset/bing/search), go to [Account Information](https://datamarket.azure.com/account), see your Primary Account Key on that page, and paste it into a file .getsecret.yaml inside the curriculum-network directory:

    bing_account_key: your_primary_account_key_goes_here

The following setup instructions are platform-specific:

### Running on Mac OS X (without Vagrant)

Make sure you have mongodb installed. On OSX, you can install it via (you'll need [homebrew](http://brew.sh/) installed):

    brew install mongodb

Now let's install some tools with npm (you'll need [nodejs](https://nodejs.org/) installed):

    npm install -g mongosrv LiveScript node-dev

Install the npm modules it depends on:

    npm install

You can start the server by running (this will start a mongodb server locally, automatically compile changed ls files, and start the node server on port 8080):

    ./runserver

You can then visit http://localhost:8080 to see the page in action

### Running on Windows (without Vagrant)

Install [chocolatey](https://chocolatey.org/) and use it to install mongodb and nodejs:

    choco install mongodb
    choco install nodejs

Now let's install some tools with npm:

    npm install -g mongosrv LiveScript node-dev

Install the npm modules it depends on:

    npm install

You can start the server by running (this will start a mongodb server locally, automatically compile changed ls files, and start the node server on port 8080):

    .\runserver

You can then visit http://localhost:8080 to see the page in action

### Running on Vagrant (alternative approach, works on both Windows and OSX)

Install [vagrant](https://www.vagrantup.com/).

Now cd to the curriculum-network directory and run vagrant up (it'll take a while the first time), followed by vagrant ssh:

    vagrant up
    vagrant ssh

You'll now be logged in inside a virtual Ubuntu environment. Now you can start the server by doing:

    ./runserver

You can then visit http://localhost:8080 to see the page in action

To ensure that files get synced over when you modify them, run (in a seperate commmand prompt window)

    vagrant rsync-auto

## URL Parameters

graph_file: you can use it to provide the name of the yaml file you wish to load. example: http://localhost:8080/?graph_file=graph_mergesort.yaml

## Graph file format

See [https://github.com/gkovacs/curriculum-network/blob/master/graph.yaml](graph.yaml) and [https://github.com/gkovacs/curriculum-network/blob/master/Astar.yaml](Astar.yaml) for examples.

## Source Layout

css files are in the css directory

js files are in the js directory

Some js files are generated from [LiveScript](http://livescript.net) files (.ls extension). The ./runserver command will automatically watch them and compile them to js files as they are changed.
