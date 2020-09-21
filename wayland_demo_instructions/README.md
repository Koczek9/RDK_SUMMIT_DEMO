# Running wayland demo
This file will help you to create wayland demo inside container using buildah. For all questions either regarding prerequisites or steps you can look inside FAQ directory for more explanations.

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
5. Put "wayland-egl-test.bb" file to some directory which gets scanned for recipies by bitbake i.e. "rdk-workspace/meta-rdk-ext/recipes-graphics/wayland"
6. Build test app
```
bitbake wayland-egl-test
```
7. Finished library should be located in "./tmp/work/cortexa7t2hf-neon-vfpv4-rdk-linux-gnueabi/wayland-egl-test/1.0-r0/image/usr/bin/wayland-egl-test"
8. Copy it to known location


## Getting dependencies - optional

1. Copy package file "wayland-egl-test" to box.
2. Run ldd against package
```
ldd --list ./wayland-egl-test
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
3. Run create_wayland_demo.sh script:
```
/vagrant/create_wayland_demo.sh
```
4. Push image to docker:
```
buildah push --creds [username]:[password] wayland_image [username]/[repository]:wayland_demo
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
bundlegen generate --creds [username]:[password] --searchpath /vagrant/bundlegen_templates --platform rpi3 --appmetadata /vagrant/wayland_demo_instruction/wayland-egl-test.json docker://[username]/[repository]:wayland_demo ./wayland_bundle
```
8. On your box create directory for test:
```
ssh root@[rpi-ip-address] "mkdir -p /opt/persistent/demo"
```
9. Copy it to box:
```
scp ./wayland_bundle.tar.gz  root@[rpi-ip-address]:/opt/persistent/demo
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
tar -xzvf wayland_bundle.tar.gz
```
13. Set permission for container rootfs:
```
chown -R non-root:non-root wayland_bundle
```
14. Add environment variable required for wayland sinc:
```
export XDG_RUNTIME_DIR=/tmp
```
15. Run wayland sink:
```
westeros --renderer /usr/lib/libwesteros_render_gl.so.0.0.0 --display westeros-dac &> /dev/null &
```
16. Set permissions for westeros socket:
```
chmod 777 /tmp/westeros-dac
```
17. Run container:
```
DobbyTool start demo ./wayland_bundle
```

