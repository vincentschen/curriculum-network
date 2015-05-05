# Creating a Simple App

Now that we have installed Meteor, let's create an app. To do this, we use Meteor's command line tool `meteor`:

```bash
meteor create microscope
```

This command will download Meteor, and set up a basic, ready to use Meteor project for you. When it's done, you should see a directory, `microscope/`, containing the following:

```bash
.meteor
microscope.css
microscope.html
microscope.js
```

The app that Meteor has created for you is a simple boilerplate application demonstrating a few simple patterns.

Even though our app doesn't do much, we can still run it. To run the app, go back to your terminal and type:

```bash
cd microscope
meteor
```

Now point your browser to `http://localhost:3000/` (or the equivalent `http://0.0.0.0:3000/`) and you should see something like this:

![welcome to meteor screenshot](/meteor/welcome_to_meteor_screenshot.png)

