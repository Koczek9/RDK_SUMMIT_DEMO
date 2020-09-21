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
cd /home/vagrant/bundlegen/
bundlegen generate --creds [username]:[password] --platform rpi3 --searchpath /vagrant/bundlegen_templates --appmetadata /vagrant/qt_app_instructions/qt-test-app.json docker://[username]/[repository]:qt-demo-app /vagrant/bundles/qt-demo-app
```

NB: This generates the bundle in `/vagrant/bundles`. That way, the bundle should be accessible on your host machine.

If for some reason the bundle does not show up on your host machine, use the `vagrant-scp` plugin on the host:
```
vagrant plugin install vagrant-scp
vagrant scp dobby-fedora:/vagrant/bundles/qt-demo-app.tar.gz .
```

### Launch the container on your Raspberry Pi

Return to your host machine.

Copy the newly generated tarball containing the OCI bundle to your Raspberry Pi, for example with scp:
```
cd [path-to-this-repo]
ssh root@[rpi-ip-address] "mkdir -p /tmp/data/bundles"
scp ./qt-demo-app.tar.gz root@[rpi-ip-address]:/tmp/data/bundles/
```

ssh into the Raspberry Pi:
```
ssh root@[rpi-ip-address]
```

Unpack the tarball:
```
cd /tmp/data/bundles/
tar -xzvf qt-demo-app.tar.gz
```

Change permission on the container rootfs:
```
chown -R non-root:non-root qt-demo-app
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

And finally, launch your container:
```
DobbyTool start qt-demo ./qt-demo-app
```
