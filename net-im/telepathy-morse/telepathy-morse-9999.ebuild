# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Telegram connection manager for Telepathy."
HOMEPAGE="https://projects.kde.org/projects/playground/network/telepathy/telepathy-morse"
#EGIT_REPO_URI="git://anongit.kde.org/telepathy-morse"
EGIT_REPO_URI="https://github.com/TelepathyQt/telepathy-morse"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	net-libs/telegram-qt
	>=net-libs/telepathy-qt-0.9.6.0
"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.12
"

DOCS=( README.md )
