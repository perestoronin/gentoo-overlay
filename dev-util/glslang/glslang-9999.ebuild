# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib cmake-utils git-r3

EGIT_REPO_URI="https://github.com/KhronosGroup/glslang.git"
SRC_URI=""

DESCRIPTION="Khronos reference front-end for GLSL and ESSL, and sample SPIR-V generator"
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"

LICENSE="BSD"
SLOT="0"

PATCHES=( "${FILESDIR}/${PN}-shared-libs.patch" )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		)

	cmake-multilib_src_configure
}

src_install() {
	cmake-multilib_src_install

	# Match SPIRV-Tools
	insinto /usr/include/SPIRV
	doins SPIRV/spirv.hpp
}
