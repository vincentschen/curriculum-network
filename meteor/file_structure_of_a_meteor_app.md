Before we begin coding, we must set up our project properly. To ensure we have a clean build, open up the microscope directory and delete `microscope.html`, `microscope.js`, and `microscope.css`.

Next, create four root directories inside `/microscope`: `/client`, `/server`, `/public`, and `/lib`.

Next, we'll also create empty `main.html` and `main.js` files inside `/client`. Don't worry if this breaks the app for now, we'll start filling in these files in the next chapter.

We should mention that some of these directories are special. When it comes to running code, Meteor has a few rules:

* Code in the `/server` directory only runs on the server
* Code in the `/client` directory only runs on the client
* Everything else runs on both the client and the server
* Your static assets (fonts, images, etc) go in the `/public` directory.

And it's also useful to know how Meteor decides in which order to load your files:

* Files in `/lib` are loaded before anything else
* Any `main.*` file is loaded after everything else
* Everything else loads in alphabetical order based on the file name.

Note that although Meteor has these rules, it doesn't really force you to use any predefined file structure for your app if you don't want to. So the structure we suggest is just our way of doing things, not a rule set in stone.

We encourage you to check out the [official Meteor docs](http://docs.meteor.com/#structuringyourapp) if you want more details on this.

