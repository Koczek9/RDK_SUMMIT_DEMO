# Running wayland demo
This file will help you to create doom demo inside container using buildah. For all questions either regarding prerequisites or steps you can look inside FAQ directory for more explanations.

## Prerequisites:
- Vagrant installed
- Fedora VM running (Vagrantfile is inside this directory)
- Buildah installed inside VM
- Bundlegen installed inside VM
- Having docker hub account (its free) to pass images [later in this instruction docker hub account will be reffered as [username] and [password]]


## Obtaining test package - optional

1. Get the bitbake recipe for your board i.e.:
```
repo init -u ssh://gerrit.teamccp.com:29418/rdk/yocto_oe/manifests/raspberrypi-manifest -m raspberrypi-cpc-mc.xml -b 2006_sprint  -g all --no-repo-verify --repo-url=ssh://gerrit.teamccp.com:29418/rdk/tools/git-repo
```
2. Synch repo:
```
repo sync --verify --no-tags -c --no-clone-bundle
```
3. Select platform:
```
source meta-rdk/setup-environment (choose raspberrypi-cpc-mc)
```
4. (Optional) Build target:
```
bitbake rdk-firebolt-mediaclient-image
```
5. Put "chocolate-doom.bb" file to some directory which gets scanned for recipies by bitbake i.e. "rdk-workspace/meta-rdk-ext/recipes-graphics/wayland"
6. Build test app
```
bitbake wayland-egl-test
```
7. Finished library should be located in "./tmp/work/cortexa7t2hf-neon-vfpv4-rdk-linux-gnueabi/wayland-egl-test/1.0-r0/image/usr/bin/wayland-egl-test"
8. Copy it to known location

### Known issues while creating a chocolate-doom package

1. Insufficient SDL version.
If you are using Morty version of yocto (Morty == Yocto Project 2.2) then libSDL libraries required by chocolate-doom are in lower version than provided. This is why in this directory you can find "recipies" directory which you can copy-paste to your bitbake directory, all recipies should build on Morty or higher version. (only chocolate-doom.bb is not in proper directory, as you can put it in several places so it is up to you to choose where to put it).

2. Pulse audio problems
Chocolate-doom requires you to have pulseadio enabled this feature is disabled by default to add it, simply add distro feature to "./meta-raspberrypi/conf/machine/raspberrypi-cpc-mc.conf":
```
DISTRO_FEATURES_append = " pulseaudio"
```
Also make sure to add:
```
TARGET_CFLAGS     += " -fomit-frame-pointer "
```
or else you can have problems with building pulseaudio.

3. libsdl2 after successfull compile fails on "do_populate" step
It does have message ``` do_populate_sysroot: QA Issue: sdl2.pc failed sanity test (tmpdir) ```. This happens because for some unknown reason "sdl2.pc" file located in:
```rdk-workspace/build-raspberrypi-cpc-mc/tmp/work/cortexa7t2hf-neon-vfpv4-rdk-linux-gnueabi/libsdl2/2.0.8-r0/sysroot-destdir/usr/lib/pkgconfig/sdl2.pc``` has wrong content of the end of file. You can simply replace lines with:
```
Libs.private: -lSDL2   -Wl,--no-undefined -lm -ldl -lpthread -lrt
Cflags: -I${includedir}/SDL2  -D_REENTRANT
```
Which is proper values and it should make "do_populate" successfully.

4. Symbols are missing from libbrcmEGL
in ```rdk-workspace/meta-raspberrypi/recipes-graphics/userland/userland_git.bb```
add additional line to SRC_URI:
'''
    file://0017_EGL_fix.patch \
'''
and paste patch "0017_EGL_fix.patch" into ```rdk-workspace/meta-raspberrypi/recipes-graphics/userland/userland/ directory``` (see https://www.mail-archive.com/yocto@yoctoproject.org/msg38949.html for details)



## Getting dependencies - optional

1. Copy package file "doom_demo" to box.
2. Run ldd against package
```
/lib/ld-linux-armhf.so.3 --list ./doom_demo
```
3. Copy all packages dependencies names
4. In bitbake directory find all dependencies names
```
find -name LIBRARY_NAME
```
and copy it to known location (most of them should be in "./rdk-workspace/build-raspberrypi-cpc-mc/tmp/work/raspberrypi_cpc_mc-rdk-linux-gnueabi/rdk-firebolt-mediaclient-image/1.0-r0/rootfs/usr/lib")
5. Repeat step 4 for all dependencies libraries

Warning you cannot just run "ldd" on your machine beacuse you will probably have different architecture of ldd. Also running "objdump ./wayland-egl-test" would be insufficient as it would just get dependencies of packet itself, without dependencies of its dependencies (https://stackoverflow.com/questions/11524820/what-is-the-difference-between-ldd-and-objdump).


# Step by step instruction

0. (Optional) Prepare library and its dependencies, if you want to skip this step all those files are in "package" directory.
1. Login to VM:
```
vagrant ssh
```
2. Switch to root:
```
sudo -s
```
3. Run create_doom_demo.sh script:
```
/vagrant/doom_demo_instructions/create_doom_demo.sh
```
4. Push image to docker:
```
buildah push --creds [username]:[password] wayland_image [username]/[repository]:doom_demo
```
5. Go to bundlegen directory:
```
cd /home/vagrant/bundlegen
```
6. (Optional) if using virtual env - Activate venv:
```
source .venv/bin/activate
```
7. Create bundle:
```
bundlegen generate --creds [username]:[password] --searchpath /vagrant/bundlegen_templates --platform rpi3 --appmetadata /vagrant/doom_demo_instruction/wayland-egl-test.json docker://[username]/[repository]:doom_demo ./doom_demo
```
8. On your box create directory for test:
```
ssh root@[rpi-ip-address] "mkdir -p /opt/persistent/demo"
```
9. Copy it to box:
```
scp ./doom_demo.tar.gz  root@[rpi-ip-address]:/opt/persistent/demo
```
10. Log in to your box (from this point all commands will be done inside box):
```
ssh root@[rpi-ip-address]
```
11. Go to test directory:
```
cd /opt/persistent/demo
```
12. Unpack it on box:
```
tar -xzvf doom_demo.tar.gz
```
13. Set permission for container rootfs:
```
chown -R non-root:non-root doom_demo
```
14. We don't need westeros sinc, but it is added into container so we are creating it so the container start successfully
```
touch /tmp/westeros-dac
```
15. Set permissions for dummy westeros socket:
```
chmod 777 /tmp/westeros-dac
```
16. Run container:
```
DobbyTool start demo ./doom_demo
```

