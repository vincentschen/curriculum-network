# Adding a Package

We will now use Meteor's package system to add the Bootstrap framework to our project.

This is no different from adding Bootstrap the usual way by manually including its CSS and JavaScript files, except that we rely on the package maintainer to keep everything up to date for us.

While we're at it, we'll also add the Underscore package. Underscore is a JavaScript utility library, and it's very useful when it comes to manipulating JavaScript data structures.

The bootstrap package is maintained by the twbs user, which gives us the full name of the package, twbs:bootstrap.

On the other hand, the underscore package is part of the “official” Meteor packages that come bundled with the framework, so it doesn't have an author:

```bash
meteor add twbs:bootstrap
meteor add underscore
```

As soon as you've added the Bootstrap package you should notice a change in our bare-bones app:

![adding a package screenshot](/meteor/adding_a_package_screenshot.png)

Unlike the “traditional” way of including external assets, we haven't had to link up any CSS or JavaScript files, because Meteor takes care of all that for us! That's just one of the many advantages of Meteor packages.

