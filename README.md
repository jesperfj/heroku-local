# Heroku Local

Build and run apps locally with Docker.

## Pre-requisites

Lots. Follow the steps below to set up.

### Download boot2docker

[Here](http://boot2docker.io/) (all this only tested on Mac)

### Install a custom ISO

You'll need an vbox ISO with VirtualBox Guest Additions added. I am using the one in [this blog post](https://medium.com/boot2docker-lightweight-linux-for-docker/boot2docker-together-with-virtualbox-guest-additions-da1e3ab2465c). Do something like this:

```
$ cd ~/.boot2docker
$ mv boot2docker.iso boot2docker.iso.orig
$ curl http://static.dockerfiles.io/boot2docker-v1.1.2-virtualbox-guest-additions-v4.3.12.iso > boot2docker.iso
$ cd - # takes you back where you came from
```


### Create and share a build folder

We're going to share a single folder for all your projects with the boot2docker VM. The VM will in turn make subfolders of this folder available as bind mounts to docker containers.

Create the folder:

    $ mkdir -p ~/.heroku/build

Share it with the boot2docker VM:

    $ VBoxManage sharedfolder add boot2docker-vm -name build -hostpath $HOME/.heroku/build

### Enable symlinks in shared folders

It's common to have symlinks in the kinds of folder structures you'll be copying/untarring to the virtualbox shared folder. Symlinks doesn't work by default with Virtual Box shared folders. Here's how to turn it on:

    $ VBoxManage setextradata boot2docker-vm VBoxInternal2/SharedFoldersEnableSymlinksCreate 1

(see [virtualbox discussion thread](https://www.virtualbox.org/ticket/10085#comment:14) for details)

### Boot the VM and mount the shared folder

Boot it with 

    $ boot2docker up

Add the mount with

     $ boot2docker ssh "sudo mkdir -p /var/heroku/build && sudo mount -t vboxsf build /var/heroku/build"

You'll probably want to add this to `/etc/rc.local` [or something](https://forums.virtualbox.org/viewtopic.php?t=15868) so it's mounted automatically when the VM boots.

### Build a container that builds Node.js apps 

For now, we're just playing with Node.js, but this approach should extend to other buildpacks:

```
$ git clone https://github.com/jesperfj/heroku-buildpack-nodejs.git
$ cd heroku-buildpack-nodejs
$ git checkout docker
$ docker build --rm -t heroku-nodejs-builder .
```

## Build

Now that you're all set, you can build a Node app from its directory with

```
$ heroku local:build
-----> Requested node range:  0.10.x
-----> Resolved node version: 0.10.30
-----> Downloading and installing node
-----> Restoring node_modules directory from cache
-----> Pruning cached dependencies not specified in package.json
-----> Installing dependencies
-----> Caching node_modules directory for future builds
-----> Cleaning up node-gyp and npm artifacts
-----> Building runtime environment
Build completed.
Cache dir: /Users/me/.heroku/build/d20140804-93297-1dpkrxw
Build dir: /Users/me/.heroku/build/d20140807-1414-slymai
```

## Problems

It's waaaaay too slow thanks to performance issues with Virtual Box shared folders. Other options:

* NFS
* Samba
* streaming tarballs in and out

