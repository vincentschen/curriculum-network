# Initializing Meteor Up

To start out, we'll need to install Meteor Up via `npm` as follows:

```bash
npm install -g mup
```

We'll then create a special, separate directory that will hold our Meteor Up settings for a particular deployment. We're using a separate directory for two reasons: first, it's usually best to avoid including any private credentials in your Git repo, especially if you're working on a public codebase.

Second, by using multiple separate directories, we'll be able to manage multiple Meteor Up configurations in parallel. This will come in handy for deploying to production and staging instances, for example.

So let's create this new directory and use it to initialize a new Meteor Up project:

```bash
mkdir ~/microscope-deploy
cd ~/microscope-deploy
mup init
```

## Sharing with Dropbox

A great way to make sure you and your team all use the same deployment settings is to simply create your Meteor Up configuration folder inside your Dropbox, or any similar service.