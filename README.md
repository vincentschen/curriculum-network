# curriculum visualization

## Demo

A live demo of this code is at http://csnet.herokuapp.com

Hovering over a node will highlight the associated nodes.

blue = children

green = depends

purple = suggests

## Curriculum Network

The curriculum network is located in graph.yaml

Each node (representing a topic) can be associated with a list of children, depends, and suggests

## Running Locally

git clone this repo, then run

    http-server

## Source Layout

css files are in the css directory

js files are in the js directory

Some js files are generated from [LiveScript](livescript.net) files (.ls extension). To compile automatically, please install it (npm install -g LiveScript) then run:

    lsc -cw .
