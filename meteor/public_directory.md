# Public Directory

OK, we lied. We don't actually need the `public/` directory for the simple reason that Microscope doesn't use any static assets! But, since most other Meteor apps are going to include at least a couple images, we thought it was important to cover it too.

By the way, you might also notice a hidden `.meteor` directory. This is where Meteor stores its own code, and modifying things in there is usually a very bad idea. In fact, you don't really ever need to look in this directory at all. The only exceptions to this are the `.meteor/`packages and `.meteor/release` files, which are respectively used to list your smart packages and the version of Meteor to use. When you add packages and change Meteor releases, it can be helpful to check the changes to these files.

