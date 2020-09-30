SUMMARY = "Chocolate Doom game"
DESCRIPTION = "Chocolate Doom game which is port of DOS game Doom"
LICENSE = "GPL"
LIC_FILES_CHKSUM = "file://COPYING.md;md5=60d644347832d2dd9534761f6919e2a6"

DEPENDS = "libsdl2 libsdl2-mixer libsdl2-net pkgconfig python-imaging"

#PREFERRED_VERSION_libsdl2 = "2.0.8"
#PREFERRED_VERSION_libsdl2-mixer = "2.0.2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

TARGET_CFLAGS     += " -fomit-frame-pointer "

S = "${WORKDIR}/git/"

SRC_URI = " \
    git://github.com/chocolate-doom/chocolate-doom.git;protocol=http;branch=master;rev=f700744969ac867649aa581ae19447a4c172179e \
"

inherit autotools


