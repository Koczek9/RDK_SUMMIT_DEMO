# To build the Raspberry Pi 3 Platco build used for these demos, follow these steps:


1. Initialise the repo and get bitbake layers:
```
cd [workspace dir]
export JOB_NAME=RPI_BUILD
repo init -u ssh://gerrit.teamccp.com:29418/rdk/yocto_oe/manifests/raspberrypi-manifest -m raspberrypi-cpc-mc.xml -b 2006_sprint  -g all --no-repo-verify --repo-url=ssh://gerrit.teamccp.com:29418/rdk/tools/git-repo
repo sync -j$(nproc) --no-clone-bundle --no-tags
```

2. Enable cpu and memory cgroups:
```
sed -i '/^CMDLINE_append.*/a CMDLINE_append = " cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1"' meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi.inc
```

3. Choose the `raspberrypi-cpc-mc` machine:
```
source meta-rdk/setup-environment # Choose 11 - raspberrypi-cpc-mc

```

4. Add DOBBY_CONTAINERS distro feature:
```
echo "DISTRO_FEATURES += \"DOBBY_CONTAINERS\"" >> ../meta-raspberrypi/conf/machine/raspberrypi-cpc-mc.conf
```

5. And finally build the image:
```
bitbake rdk-firebolt-mediaclient-image
```
