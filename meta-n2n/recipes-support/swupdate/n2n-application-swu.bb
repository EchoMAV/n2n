DESCRIPTION = "Artifact recipe for the N2N Application"
SECTION = ""

inherit swupdate

LICENSE = "CLOSED"

# Note: sw-description is mandatory
SRC_URI = " \
	file://n2n-application.tar.gz \
	file://sw-description \
	file://n2n-update.sh \
"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = " \
	n2n \
"

SWUPDATE_IMAGES_NOAPPEND_MACHINE[var-som-mx6-ornl] = "1"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
SWUPDATE_IMAGES_FSTYPES[n2n-application] = ".tar.gz"
