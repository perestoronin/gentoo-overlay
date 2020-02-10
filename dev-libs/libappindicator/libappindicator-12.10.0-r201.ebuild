# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"

inherit autotools eutils multilib-minimal vala xdg-utils

DESCRIPTION="A library to allow applications to export a menu into the Unity Menu bar"
HOMEPAGE="https://launchpad.net/libappindicator"
SRC_URI="https://launchpad.net/${PN}/${PV%.*}/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="2"
KEYWORDS="amd64 ~arm x86"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/dbus-glib-0.98[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.26:2[${MULTILIB_USEDEP}]
	>=dev-libs/libdbusmenu-0.6.2[gtk,${MULTILIB_USEDEP}]
	>=dev-libs/libindicator-12.10.0:0[${MULTILIB_USEDEP}]
	x11-libs/gtk+:2[${MULTILIB_USEDEP},introspection?]
	introspection? ( >=dev-libs/gobject-introspection-1:= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	introspection? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${P}-conditional-py-bindings.patch
	# http://bazaar.launchpad.net/~indicator-applet-developers/libappindicator/trunk.12.10/revision/244
	"${FILESDIR}"/${P}-vala-inherit.patch
)

pkg_setup() {
	export MAKEOPTS+=" -j1" #638782
}

src_prepare() {
	default

	xdg_environment_reset

	# Don't use -Werror
	sed -i -e 's/ -Werror//' {src,tests}/Makefile.{am,in} || die

	eautoreconf

	# Disable MONO for now because of https://bugs.gentoo.org/382491
	sed -i -e '/^MONO_REQUIRED_VERSION/s:=.*:=9999:' configure || die
}

multilib_src_configure() {
	if multilib_is_native_abi; then
		local -x VALAC VALA_API_GEN VAPIGEN_VAPIDIR PKG_CONFIG_PATH
		use introspection && vala_src_prepare && export VALA_API_GEN="${VAPIGEN}"
	fi

	ECONF_SOURCE=${S} \
	econf \
		--disable-static \
		--with-gtk=2 \
		$(multilib_native_use_enable introspection) \
		--disable-python
}

multilib_src_install() {
	emake -j1 DESTDIR="${D}" install
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files --modules

	# installed by slot 3 as well
	rm -r "${D}"usr/share/gtk-doc || die
}
