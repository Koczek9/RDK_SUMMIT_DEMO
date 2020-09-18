#!/usr/bin/env bash

# create new image
newcontainer=$(buildah from scratch)

# rename container
containername=wayland_demo
buildah rename $newcontainer $containername

# copy demo to container rootfs
buildah copy $containername /vagrant/wayland_demo_instructions/package/wayland-egl-test /usr/bin/

# copy all libraires dependencies
buildah copy $containername /vagrant/wayland_demo_instructions/package/lib /lib
buildah copy $containername /vagrant/wayland_demo_instructions/package/usr/lib /usr/lib

# set demo to autoplay
buildah config --cmd /usr/bin/wayland-egl-test $containername

# create image
buildah commit $containername wayland_image

