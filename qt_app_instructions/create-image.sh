#!/usr/bin/env bash

# delete container if it already exists
containername=qt-demo-app
buildah rm $containername

# create new image from scratch
newcontainer=$(buildah from scratch)

# rename container
buildah rename $newcontainer $containername

# copy demo to container rootfs
buildah copy $containername ./package/openglwindow /openglwindow

# copy libraries that the demo is dependant on
buildah copy $containername ./package/lib /lib
buildah copy $containername ./package/usr/lib /usr/lib
buildah copy $containername ./package/usr/lib/qt5/plugins/platforms/libqeglfs.so /usr/lib/qt5/plugins/platforms/

# set demo to autoplay
buildah config --cmd "/openglwindow -platform eglfs" $containername

# create image
buildah commit $containername qt-demo-app-image
