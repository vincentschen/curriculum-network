# Deploying On Meteor

Deploying on a Meteor subdomain (i.e. `http://myapp.meteor.com`) is the easiest option, and the first one we'll try. This can be useful to showcase your app to others in its early days, or to quickly set up a staging server.

Deploying on Meteor is pretty simple. Just open up your terminal, go to to your Meteor app's directory, and type:

```bash
meteor deploy myapp.meteor.com
```

Of course, you'll have to take care to replace "myapp" with a name of your choice, preferably one that isn't already in use.

If this is your first time deploying an app, you'll be prompted to create a Meteor account. And if all goes well, after a few seconds you'll be able to access your app at http://myapp.meteor.com.

You can refer to the [official documentation](http://docs.meteor.com/#deploying) for more information on things like accessing your hosted instance's database directly, or configuring a custom domain for your app.