
## Creating your own demo app package (OPTIONAL)

The demo app package can be found in `./package/`, containing the executable binary `openglwindow` and its library dependencies and plugins required to launch it in a container.

The example binary is found at `./package/openglwindow`.

To create your own package, you will need to create your own `./package/` directory and contents by copying them from a Raspberry Pi 3 image.

### Build instruction extras

Follow the instructions in `FAQ/building-rpi-image.md`, and run the following to install the `openglwindow` example in `/` on the Raspberry Pi.

```
echo "
QT_CONFIG_FLAGS += \" -make examples\"
do_install_append() {
        install -D -m 0644 \${S}/../../../build/examples/gui/openglwindow/openglwindow \${D}/openglwindow
}
" >> meta-raspberrypi/recipes-qt/qt5/qtbase_%.bbappend
```

### Figuring out dependencies

To figure out the dependencies of the package, you can use `ldd [binary-path]` (or `/lib/ld-linux-armhf.so.3 --list [binary-path]` on RDK builds).

Any Qt plugins used will be loaded dynamically, so you will need to copy their dependencies as well.
