DESCRIPTION = "This will replace the current image with an image speciic to N2N with all its dependencies"
SECTION = ""

inherit swupdate

LICENSE = "CLOSED"

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://var-update.sh \
"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "n2n-full-image"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory
SWUPDATE_IMAGES = " \
    n2n-full-image \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
SWUPDATE_IMAGES_FSTYPES[n2n-full-image] = ".tar.gz"