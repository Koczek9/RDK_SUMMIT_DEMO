#!/usr/bin/env bash

# create new image
newcontainer=$(buildah from scratch)

# rename container
containername=qt-demo-app
buildah rename $newcontainer $containername

# copy demo to container rootfs
buildah copy $containername ./package/bin /usr/bin/

# copy libraries that the demo is dependant on
buildah copy $containername ./package/lib /lib
buildah copy $containername ./package/usr/lib /usr/lib

# set demo to autoplay
buildah config --cmd /usr/bin/qt-demo-app $containername

# create image
buildah commit $containername qt-demo-app-image

