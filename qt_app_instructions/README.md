# Creating a DAC Qt Demo Application

With these instructions, you'll be able to create and launch a simple Qt Application in a container.

We'll go through steps on creating an OCI image, generating an OCI bundle out of that image and then finally using that bundle to launch your container on your Raspberry Pi using Dobby.

## Prerequisites

It is assumed that you have set up a Vagrant VM based on the instructions in this repo's root `README.md`.

All of the following will be run on the VM. Run `vagrant ssh` in the repository's root directory if you're not already ssh'd in.

## Setup

### Switch to root

buildah requires root access so we want to enable it

```
sudo -s
```

### Create image and push it to your docker repository

Run the image creation script:
```
/vagrant/qt_app_instructions/create-image.sh
```

Push the image to your Docker Hub repository
```
buildah push --creds [username]:[password] qt-demo-app-image [username]/[repository]:qt-demo-app
```

### Generate OCI bundle from image

To launch our application in a container with Dobby, the application needs to be available as an OCI bundle.


Let's generate an OCI bundle using the image we've just created and uploaded to Docker Hub using `BundleGen`
```
cd /home/vagrant/bundlegen/
bundlegen generate --creds [username]:[password] --platform rpi3 --appmetadata /home/vagrant/RDK_SUMMIT_DEMO/qt-demo-app.json docker://[username]/[repository]:qt-demo-app /vagrant/qt-app-bundle
```

NB: This generates the bundle in `/vagrant`. That way, the bundle is accessible on your host machine.

### Launch the container on your Raspberry Pi

Return to your host machine.

Copy the newly generated tarball containing the OCI bundle to your Raspberry Pi, for example with scp:
```
cd [path-to-this-repo]
scp -P 10022 ./qt-app-bundle.tar.gz root@[rpi-ip-address]:/tmp/data/bundles/
```

ssh into the Raspberry Pi:
```
ssh -P 10022 root@[rpi-ip-address]
```

Unpack the tarball:
```
cd /tmp/data/bundles/
tar -xzvf qt-app-bundle.tar.gz
```

Change permission on the container rootfs:
```
chown -R non-root:non-root qt-app-bundle
```

Launch wayland sink (and set permissions for the socket):
```
export XDG_RUNTIME_DIR=/tmp
westeros --renderer /usr/lib/libwesteros_render_gl.so.0.0.0 --display westeros-dac
chmod 777 /tmp/westeros-dac
```

And finally, launch your container:
```
DobbyTool start qt-demo ./qt-app-bundle
```
