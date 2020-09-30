#!/usr/bin/env bash

# create new image
newcontainer=$(buildah from scratch)

# rename container
containername=doom_demo
buildah rename $newcontainer $containername

# copy demo to container rootfs
buildah copy $containername /vagrant/doom_demo_instructions/package/chocolate-doom /usr/bin/

# copy all libraires dependencies
buildah copy $containername /vagrant/doom_demo_instructions/package/lib /lib
buildah copy $containername /vagrant/doom_demo_instructions/package/usr/lib /usr/lib

# copy wad file (chocolate-doom is the engine, doom.wad are the graphics+sounds files)
buildah copy $containername /vagrant/doom_demo_instructions/package/opt/persistent /opt/persistent

# add environment variable
buildah config --env HOME="/home/root/" $containername

# add empty directory for home
buildah copy $containername /vagrant/doom_demo_instructions/package/home/root/ /home/root/

# set demo to autoplay
buildah config --cmd "/usr/bin/chocolate-doom -iwad /opt/persistent/doom1.wad" $containername

# create image
buildah commit $containername doom_image


