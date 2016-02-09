# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/pcsxr/pcsxr-1.9.94.ebuild,v 1.2 2013/12/11 19:07:06 mgorny Exp $

EAPI=5

EGIT_REPO_URI="https://github.com/mirror/pcsxr.git"

inherit autotools eutils games git-r3

DESCRIPTION="PCSX-Reloaded: a fork of PCSX, the discontinued Playstation emulator"
HOMEPAGE="http://pcsxr.codeplex.com"
LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa cdio ffmpeg nls openal opengl oss pulseaudio +sdl"

# pcsxr supports both SDL1 and SDL2 but uses the newer version installed
# since SDL is not properly slotted in Gentoo, just fix it on SDL2

RDEPEND="dev-libs/glib:2=
	media-libs/libsdl:0=[joystick]
	sys-libs/zlib:0=
	x11-libs/gtk+:3=
	x11-libs/libX11:0=
	x11-libs/libXext:0=
	x11-libs/libXtst:0=
	x11-libs/libXv:0=
	alsa? ( media-libs/alsa-lib:0= )
	cdio? ( dev-libs/libcdio:0= )
	ffmpeg? ( virtual/ffmpeg:0= )
	nls? ( virtual/libintl:0= )
	openal? ( media-libs/openal:0= )
	opengl? ( virtual/opengl:0=
		x11-libs/libXxf86vm:0= )
	pulseaudio? ( media-sound/pulseaudio:0= )
	sdl? ( media-libs/libsdl:0= )"
DEPEND="${RDEPEND}
	app-arch/unzip
	dev-util/intltool
	x11-proto/videoproto
	nls? ( sys-devel/gettext:0 )
	x86? ( dev-lang/nasm )"

REQUIRED_USE="?? ( alsa openal oss pulseaudio sdl )"

# it's only the .po file check that fails :)
RESTRICT=test

src_prepare() {
	mkdir ${S}/include || die

	local PATCHES=(
		"${FILESDIR}"/${PN}-disable-sdl2.patch
		"${FILESDIR}"/${PN}-install-paths.patch
	)

	epatch "${PATCHES[@]}"
	epatch_user
	eautoreconf
}

src_configure() {
	local sound_backend

	if use alsa; then
		sound_backend=alsa
	elif use oss; then
		sound_backend=oss
	elif use pulseaudio; then
		sound_backend=pulseaudio
	elif use sdl; then
		sound_backend=sdl
	elif use openal; then
		sound_backend=openal
	else
		sound_backend=null
	fi

	local myeconfargs=(
		--datarootdir="${EPREFIX%/}"/usr/share

		$(use_enable nls)
		$(use_enable cdio libcdio)
		$(use_enable opengl)
		$(use_enable ffmpeg ccdda)
		--enable-sound=${sound_backend}
	)

	egamesconf "${myeconfargs[@]}"
}

src_install() {
	default
	prune_libtool_files --all

	dodoc doc/{keys,tweaks}.txt
	prepgamesdirs
}
