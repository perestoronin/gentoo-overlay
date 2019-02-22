# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PLOCALES="ar ca cs da de el en es fa fr hr hu it ja ko ms nb nl pl pt pt_BR ro ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"

inherit cmake-utils desktop gnome2-utils l10n pax-utils

if [[ ${PV} == 9999* ]]
then
	EGIT_REPO_URI="https://github.com/dolphin-emu/dolphin"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}-emu/${PN}/archive/${PV}.zip -> ${P}.zip"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Gamecube and Wii game emulator"
HOMEPAGE="https://www.dolphin-emu.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa bluetooth doc egl +evdev ffmpeg llvm log lto profile pulseaudio +qt5 sdl upnp"

RDEPEND=">=media-libs/libsfml-2.1
	>net-libs/enet-1.3.7
	>=net-libs/mbedtls-2.1.1
	dev-libs/lzo
	media-libs/libpng:=
	sys-libs/glibc
	sys-libs/readline:=
	sys-libs/zlib
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	virtual/libusb:1
	virtual/opengl
	media-libs/mesa[vulkan]
	dev-util/glslang
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	egl? ( media-libs/mesa[egl] )
	evdev? (
			dev-libs/libevdev
			virtual/udev
	)
	ffmpeg? ( virtual/ffmpeg )
	llvm? ( sys-devel/llvm )
	profile? ( dev-util/oprofile )
	pulseaudio? ( media-sound/pulseaudio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	sdl? ( media-libs/libsdl2[haptic,joystick] )
	upnp? ( >=net-libs/miniupnpc-1.7 )
	media-libs/vulkan-loader
	dev-libs/hidapi
	dev-libs/pugixml
	"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.8
	>=sys-devel/gcc-4.9.0
	>=dev-libs/xxhash-0.6.2
	dev-cpp/picojson
	dev-cpp/gtest
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig
	"

PATCHES=( "${FILESDIR}/exceptions.patch"
		  "${FILESDIR}/force_cxx17.patch"
		  "${FILESDIR}/gentoo-vulkan.patch"
		  "${FILESDIR}/picojson.patch"
		  "${FILESDIR}/qt_force_cxx17.patch"
		  "${FILESDIR}/system-libs.patch" )

src_prepare() {
	cmake-utils_src_prepare

	# Remove all the bundled libraries that support system-installed
	# preference. See CMakeLists.txt for conditional 'add_subdirectory' calls.
	local KEEP_SOURCES=(
		Bochs_disasm
		cpp-optparse
		# imgui is not in tree and not intended to be shared
		imgui
		# soundtouch uses shorts, not floats
		soundtouch
		cubeb
		# Their build set up solely relies on the build in gtest.
		gtest
		# minizip is stripped-down
		minizip
		# FreeSurround is not in tree
		FreeSurround
	)
	local s
	for s in "${KEEP_SOURCES[@]}"; do
		mv -v "Externals/${s}" . || die
	done
	einfo "removing sources: $(echo Externals/*)"
	rm -r Externals/* || die "Failed to delete Externals dir."
	for s in "${KEEP_SOURCES[@]}"; do
		mv -v "${s}" "Externals/" || die
	done

	remove_locale() {
		# Ensure preservation of the backup locale when no valid LINGUA is set
		if [[ "${PLOCALE_BACKUP}" == "${1}" ]] && [[ "${PLOCALE_BACKUP}" == "$(l10n_get_locales)" ]]; then
			return
		else
			rm "Languages/po/${1}.po" || die
		fi
	}

	l10n_find_plocales_changes "Languages/po/" "" '.po'
	l10n_for_each_disabled_locale_do remove_locale
}

src_configure() {

	local mycmakeargs=(
		-DENABLE_ANALYTICS=OFF
		-DUSE_SHARED_ENET=ON
		-DUSE_SHARED_XXHASH=ON
		-DUSE_SHARED_GLSLANG=ON
		-DUSE_DISCORD_PRESENCE=OFF
		-DENCODE_FRAMEDUMPS=$(usex ffmpeg)
		-DFASTLOG=$(usex log)
		-DOPROFILING=$(usex profile)
		-DENABLE_EVDEV=$(usex evdev)
		-DENABLE_LTO=$(usex lto)
		-DENABLE_LLVM=$(usex llvm)
		-DENABLE_QT=$(usex qt5)
		-DENABLE_SDL=$(usex sdl ON OFF)
		-DENABLE_ALSA=$(usex alsa ON OFF)
		-DENABLE_PULSEAUDIO=$(usex pulseaudio)
		-DUSE_EGL=$(usex egl)
		-DUSE_UPNP=$(usex upnp)
	)

	cmake-utils_src_configure
}

src_install() {

	cmake-utils_src_install

	dodoc Readme.md
	if use doc; then
		dodoc -r docs/ActionReplay docs/DSP docs/WiiMote
	fi

	doicon -s 48 Data/dolphin-emu.png
	doicon -s scalable Data/dolphin-emu.svg
	doicon Data/dolphin-emu.svg
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/bin/"${PN}"-emu-nogui
	if use qt5; then
		pax-mark -m "${EPREFIX}"/usr/bin/"${PN}"-emu
	fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
