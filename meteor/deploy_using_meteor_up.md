# Meteor Up

Although new cloud solutions are appearing every day, they often come with their own share of problems and limitations. So as of today, deploying on your own server remains the best way to put a Meteor application in production. The only thing is, deploying yourself is not that simple, especially if you're looking for production-quality deployment.

[Meteor Up](https://github.com/arunoda/meteor-up) (or `mup` for short) is another attempt at fixing that issue, with a command-line utility that takes care of setup and deployment for you. So let's see how to deploy Microscope using Meteor Up.

Before anything else, we'll need a server to push to. We recommend either [Digital Ocean](http://digitalocean.com/), which starts at $5 per month, or [AWS](http://aws.amazon.com/), which provides Micro instances for free (you'll quickly run into scaling problems, but if you're just looking to play around with Meteor Up it should be enough).

Whichever service you choose, you should end up with three things: your server's IP address, a login (usually `root` or `ubuntu`), and a password. Keep those somewhere safe, we'll need them soon!