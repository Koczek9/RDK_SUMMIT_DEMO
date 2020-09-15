This file will help you to create wayland demo inside container using buildah. For all questions either regarding prerequisites or steps you can look inside FAQ directory for more explanations.

Prerequisites:
- Vagrant installed
- Fedora VM running (Vagrantfile is inside this directory)
- Buildah installed inside VM
- Bundlegen installed inside VM
- Having docker hub account (its free) to pass images [later in this instruction docker hub account will be reffered as YourUserName and YourPassword]

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