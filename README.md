# Creating a DAC app

This repository contains step-by-step instructions for creating simple DAC applications to run on a Raspberry Pi RDK-V build.

Using these instructions, you should be able to create a simple application and launch it in a Dobby container.

## Getting started

For the purposes of these instructions, we'll be working inside a Fedora-based Virtual Machine environment to ensure compatibility with the tools we'll be using.

If you've not used Vagrant before, take a look at the instructions in `FAQ/vagrant-how-to-install`.

Once inside the virtual machine, you'll need to install the following:

- Buildah (see `FAQ/buildah-how-to-setup.txt` for instructions)
- BundleGen (see `FAQ/bundlegen-how-to-setup.txt` for instructions)

You will also need a Docker Hub account (see `FAQ/docker-hub-how-to-setup` for instructions).

Once you have these set up, you're ready to create a DAC app using the instructions in `wayland_demo_instructions` or `qt_app_instructions`.

TODO: check instructions for Windows machines

## Hardware requirements

TODO - Raspberry Pi 3B, but which image?
