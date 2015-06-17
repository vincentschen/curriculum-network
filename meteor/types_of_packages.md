# A Note on Packages

When speaking about packages in the context of Meteor, it pays to be specific. Meteor uses five basic types of packages:

* The Meteor core itself is split into different *Meteor platform packages*. They are included with every Meteor app, and you will pretty much never need to worry about these.
* Regular Meteor packages are known as "*isopacks*", or isomorphic packages (meaning they can work both on client and server). *First-party packages* such as `accounts-ui` or `appcache` are maintained by the Meteor core team and [come bundled with Meteor](http://docs.meteor.com/#packages).
* *Third-party packages* are just isopacks developed by other users that have been uploaded to Meteor's package server. You can browse them on [Atmosphere](http://atmosphere.meteor.com/) or with the `meteor search` command.
* *Local packages* are custom packages you can create yourself and put in the `/packages` directory.
NPM packages (Node.js Packaged Modules) are Node.js packages. Although they don't work out of the box with Meteor, they can be used by the previous types of packages.
