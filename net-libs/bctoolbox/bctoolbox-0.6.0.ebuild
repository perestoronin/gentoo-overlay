# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib pax-utils versionator cmake-utils

DESCRIPTION="Bellecom toolbox"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/bctoolbox/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# TODO: run-time test for ipv6: does it need mediastreamer[ipv6]?
IUSE="polarssl +mbedtls test"

RDEPEND=""
DEPEND="${RDEPEND}
		polarssl? ( net-libs/polarssl )
		mbedtls? ( net-libs/mbedtls )"
REQUIRED_USE="^^ ( polarssl mbedtls )"

PATCHES="${FILESDIR}/fix_cmake_no_git_repo.patch"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_STRICT=NO
		-DENABLE_TUTORIALS=NO
		-DENABLE_MBEDTLS="$(usex mbedtls)"
		-DENABLE_POLARSSL="$(usex polarssl)"
		-DENABLE_TESTS="$(usex test)"
		-DENABLE_TESTS_COMPONENT="$(usex test)"
	)

	cmake-utils_src_configure
}
