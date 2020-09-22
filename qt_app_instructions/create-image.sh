#!/usr/bin/env bash

containername=qt-demo-app

# delete container if it already exists
containerstatus=$(buildah inspect $containername 2>&1)
if [[ ! $containerstatus =~ "error locating image" ]]; then
        echo "Removing old container $containername..."
        buildah rm $containername
fi

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

