DESCRIPTION = "Provide access to N2N drivers"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require ../../../meta-ornl/recipes-core/images/ornl-dev-image.bb

IMAGE_INSTALL_append += " \
    n2n \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    u-boot-variscite \
"
