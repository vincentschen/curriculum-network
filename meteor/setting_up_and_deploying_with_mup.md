# Setting Up and Deploying

Before we can deploy, we'll need to set up the server so it's ready to host Meteor apps. The magic of Meteor Up encapsulates this complex process in a single command!

```bash
mup setup
```

This will take a few minutes depending on the server's performance and the network connectivity. After the setup is successful, we can finally deploy our app with:

```bash
mup deploy
```

This will bundle the meteor app, and deploy to the server we just set up.
