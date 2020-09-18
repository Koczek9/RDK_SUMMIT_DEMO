# Running wayland demo
This file will help you to create wayland demo inside container using buildah. For all questions either regarding prerequisites or steps you can look inside FAQ directory for more explanations.

## Prerequisites:
- Vagrant installed
- Fedora VM running (Vagrantfile is inside this directory)
- Buildah installed inside VM
- Bundlegen installed inside VM
- Having docker hub account (its free) to pass images [later in this instruction docker hub account will be reffered as YourUserName and YourPassword]


## Obtaining test package

1. Get the bitbake recipe for your board i.e.: repo init -u ssh://gerrit.teamccp.com:29418/rdk/yocto_oe/manifests/raspberrypi-manifest -m raspberrypi-cpc-mc.xml -b 2006_sprint  -g all --no-repo-verify --repo-url=ssh://gerrit.teamccp.com:29418/rdk/tools/git-repo
2. Synch repo: repo sync --verify --no-tags -c --no-clone-bundle
3. Select platform: source meta-rdk/setup-environment (choose raspberrypi-cpc-mc)
4. (Optional) Build target: bitbake rdk-firebolt-mediaclient-image
5. Put "wayland-egl-test.bb" file to some directory which gets scanned for recipies by bitbake i.e. "rdk-workspace/meta-rdk-ext/recipes-graphics/wayland"
6. Build test app "bitbake wayland-egl-test"
7. Finished library should be located in "./tmp/work/cortexa7t2hf-neon-vfpv4-rdk-linux-gnueabi/wayland-egl-test/1.0-r0/image/usr/bin/wayland-egl-test"
8. Copy it to known location


## Getting dependencies

1. Copy package file "wayland-egl-test" to box.
2. Run ldd against package "ldd --list ./wayland-egl-test"
3. Copy all packages dependencies names
4. In bitbake directory of your build run "find -name LIBRARY_NAME" and copy it to known location (most of them should be in "./rdk-workspace/build-raspberrypi-cpc-mc/tmp/work/raspberrypi_cpc_mc-rdk-linux-gnueabi/rdk-firebolt-mediaclient-image/1.0-r0/rootfs/usr/lib")
5. Repeat step 4 for all dependencies libraries

Warning you cannot just run "ldd" on your machine beacuse you will probably have different architecture of ldd. Also running "objdump ./wayland-egl-test" would be insufficient as it would just get dependencies of packet itself, without dependencies of its dependencies (https://stackoverflow.com/questions/11524820/what-is-the-difference-between-ldd-and-objdump).


# Step by step instruction

0. Prepare library and its dependencies
1. Login to VM: vagrant ssh
2. Switch to root: sudo -s
3. Run create_wayland_demo.sh script: /vagrant/create_wayland_demo.sh
4. Push image to docker: buildah push --creds YourUserName:YourPassword wayland_image YourUserName/testrepository:wayland_demo
5. Go to bundlegen directory: cd /bundlegen
6. (Optional) if using virtual env - Activate venv: source .venv/bin/activate
7. Create bundle: bundlegen generate --creds YourUserName:YourPassword --platform xi6 --appmetadata sample_app_metadata/wayland-egl-test.json docker://YourUserName/testrepository:wayland_demo ./wayland_bundle
8. Copy it to box: scp -P 10022 ./wayland_bundle.tar.gz  root@10.42.0.19:/tmp/demo/
9. Unpack it on box: tar -xzvf wayland_bundle.tar.gz
10. Set permission for container rootfs: chown -R non-root:non-root wayland_bundle
11. Run wayland sink in other terminal: export XDG_RUNTIME_DIR=/tmp
westeros --renderer /usr/lib/libwesteros_render_gl.so.0.0.0 --display westeros-dac
12. Set permissions for westeros socket: chmod 777 /tmp/westeros-dac
13. Run container: DobbyTool start demo ./wayland_bundle

