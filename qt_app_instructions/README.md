# Creating a DAC Qt Demo Application

With these instructions, you'll be able to create and launch a simple Qt Application in a container.

We'll go through steps on creating an OCI image, generating an OCI bundle out of that image and then finally using that bundle to launch your container on your Raspberry Pi using Dobby.

## Prerequisites

It is assumed that you have set up a Vagrant VM based on the instructions in this repo's root `README.md`.

All of the following will be run on the VM. Run `vagrant ssh` in the repository's root directory if you're not already ssh'd in.

**OPTIONAL** - If you want to go through the pain of creating your own package from scratch, refer to `./package-creation-instructions.md`.

## Setup

### Switch to root

buildah requires root access so we want to enable it:
```
sudo -s
```

### Create image and push it to your docker repository

To create an image, we use buildah to first create an image from scratch, to which we add a package containing the `openglwindow` Qt example binary, as well as the dependencies it has. We do this using the `create-image.sh` script.

Run the image creation script:
```
cd /vagrant/qt_app_instructions/
./create-image.sh
```

Push the image to your Docker Hub repository:
```
buildah push --creds [username]:[password] qt-demo-app-image [username]/[repository]:qt-demo-app
```

### Generate OCI bundle from image

To launch our application in a container with Dobby, the application needs to be available as an OCI bundle.

Let's generate an OCI bundle using the image we've just created and uploaded to Docker Hub using `BundleGen`:
```
cd /home/vagrant/BundleGen/
bundlegen generate --creds [username]:[password] --platform rpi3 --appmetadata /vagrant/qt_app_instructions/qt-test-app.json docker://[username]/[repository]:qt-demo-app ./qt-demo-app
```


# Launch the container on your Raspberry Pi

## Get the bundle to the Raspberry Pi device

Copy the newly generated tarball containing the OCI bundle to your Raspberry Pi, for example with scp:
```
ssh root@[rpi-ip-address] "mkdir -p /opt/persistent/bundles"
scp ./qt-demo-app.tar.gz root@[rpi-ip-address]:/opt/persistent/bundles/
```

Return to your host machine and ssh into the Raspberry Pi:
```
ssh root@[rpi-ip-address]
```

Unpack the tarball:
```
cd /opt/persistent/bundles/
tar -xzvf qt-demo-app.tar.gz
```

## Prepare the app to be launched from the bundle

Change permission on the container rootfs:
```
chown -R non-root:non-root qt-demo-app
```

The graphics device on the Raspberry Pi is owned by root. We're using user namespacing in the container so we'll need to relax the permissions for the graphics device a bit:
```
chmod 777 /dev/vchiq
```

The `rpi3.json` platform template adds the `/tmp/westeros-dac` mount to add a Westeros socket to the container, but we don't need it, so let's just create a dummy file to mount:
```
touch /tmp/westeros-dac
```

Kill any open GUI apps being drawn on the screen. For example to kill plui on the Raspberry Pi 3 build:
```
curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:9998/jsonrpc' -d '{"jsonrpc": "2.0","id": 4,"method": "Controller.1.deactivate", "params": { "callsign": "ResidentApp" }}' ; echo
curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:9998/jsonrpc' -d '{"jsonrpc": "2.0","id": 4,"method": "Controller.1.deactivate", "params": { "callsign": "SearchAndDiscoveryApp" }}' ; echo
```

## Launch the app in a container

And finally, to launch your container:
```
DobbyTool start qt-demo ./qt-demo-app
```
