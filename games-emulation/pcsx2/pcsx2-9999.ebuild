# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

WX_GTK_VER="3.1-gtk3"

inherit cmake flag-o-matic git-r3 toolchain-funcs wxwidgets fcaps

DESCRIPTION="A PlayStation 2 emulator"
HOMEPAGE="https://www.pcsx2.net"
EGIT_REPO_URI="https://github.com/PCSX2/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	app-arch/bzip2[abi_x86_32(-)]
	app-arch/xz-utils[abi_x86_32(-)]
	dev-libs/libaio[abi_x86_32(-)]
	dev-libs/libxml2:2[abi_x86_32(-)]
	media-libs/alsa-lib[abi_x86_32(-)]
	media-libs/libpng:=[abi_x86_32(-)]
	media-libs/libsdl2[abi_x86_32(-),haptic,joystick,sound]
	media-libs/libsoundtouch[abi_x86_32(-)]
	media-libs/portaudio[abi_x86_32(-)]
	net-libs/libpcap[abi_x86_32(-)]
	sys-libs/zlib[abi_x86_32(-)]
	virtual/libudev[abi_x86_32(-)]
	virtual/opengl[abi_x86_32(-)]
	x11-libs/gtk+:3[abi_x86_32(-)]
	x11-libs/libICE[abi_x86_32(-)]
	x11-libs/libX11[abi_x86_32(-)]
	x11-libs/libXext[abi_x86_32(-)]
	>=x11-libs/wxGTK-3.0.4-r301:3.0-gtk3[abi_x86_32(-),X]
"
DEPEND="${RDEPEND}
	dev-cpp/pngpp
	dev-cpp/sparsehash
"

FILECAPS=(
	"CAP_NET_RAW+eip CAP_NET_ADMIN+eip" usr/bin/PCSX2
)

PATCHES=( "${FILESDIR}/libcommon-glad-static.patch"
		  "${FILESDIR}/visibility.patch"
		  "${FILESDIR}/link-to-rt.patch" )

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary && $(tc-getCC) == *gcc* ]]; then
		# -mxsave flag is needed when GCC >= 8.2 is used
		# https://bugs.gentoo.org/685156
		if [[ $(gcc-major-version) -gt 8 || $(gcc-major-version) == 8 && $(gcc-minor-version) -ge 2 ]]; then
			append-flags -mxsave
		fi
	fi
}

src_prepare() {
	rm -rf 3rdparty/fmt || die
	cmake_src_prepare
}

src_configure() {
	# multilib_toolchain_setup x86
	# Build with ld.gold fails
	# https://github.com/PCSX2/pcsx2/issues/1671
	tc-ld-disable-gold

	# pcsx2 build scripts will force CMAKE_BUILD_TYPE=Devel
	# if it something other than "Devel|Debug|Release"
	local CMAKE_BUILD_TYPE="Release"

	# if use amd64; then
	# 	# Passing correct CMAKE_TOOLCHAIN_FILE for amd64
	# 	# https://github.com/PCSX2/pcsx2/pull/422
	# 	local MYCMAKEARGS=(-DCMAKE_TOOLCHAIN_FILE=cmake/linux-compiler-i386-multilib.cmake)
	# fi

	local mycmakeargs=(
		-DARCH_FLAG=
		-DDISABLE_BUILD_DATE=TRUE
		-DDISABLE_PCSX2_WRAPPER=TRUE
		-DEXTRA_PLUGINS=FALSE
		-DOPTIMIZATION_FLAG=
		-DPACKAGE_MODE=TRUE
		-DXDG_STD=TRUE
		-DDISABLE_SETCAP=TRUE
		-DCMAKE_LIBRARY_PATH="/usr/$(get_libdir)/${PN}"
		-DDOC_DIR=/usr/share/doc/"${PF}"
		-DPLUGIN_DIR="/usr/$(get_libdir)/${PN}"
		# wxGTK must be built against same sdl version
		-DSDL2_API=TRUE
		-DUSE_VTUNE=FALSE
	)

	setup-wxwidgets
	cmake_src_configure
}

src_install() {
	# Upstream issues:
	#  https://github.com/PCSX2/pcsx2/issues/417
	#  https://github.com/PCSX2/pcsx2/issues/3077
	QA_EXECSTACK="usr/bin/PCSX2"
	QA_TEXTRELS="usr/$(get_libdir)/pcsx2/* usr/bin/PCSX2"
	cmake_src_install
}
