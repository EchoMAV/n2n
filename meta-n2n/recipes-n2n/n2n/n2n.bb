SUMMARY = "LoS build recipe, this SHOULD put all files in the correct place and enable the service"
DESCRIPTION = "TBD"
SECTION = "misc"
LICENSE = "CLOSED"

FILESEXTRAPATH_prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://n2n.tar.gz"

RDEPENDS_${PN} += " bash python3-bottle python3-pyserial"

S="${WORKDIR}"

FILES_${PN} += " \
    ${systemd_unitdir}/system/edge.service \
"

FILES_${PN} += " \
    /root/n2n/* \
"

do_install() {
    mkdir -p ${D}/root/n2n
    install -d ${D}/root/n2n

    cp -rf ${S}/n2n/* ${D}/root/n2n/
    rm -f ${D}/root/n2n/*.tar.gz

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${S}/n2n/edge.service ${D}${systemd_system_unitdir}/

        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
        ln -sf ${systemd_system_unitdir}/edge.service \
            ${D}${sysconfdir}/systemd/system/multi-user.target.wants/edge.service
    fi
}
