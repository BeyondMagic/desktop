# Nushell Environment Login File
#
# Configuration with login.nu
#
# If Nushell is used as a login shell, you can use a specific configuration file which is only sourced in this case. Therefore a file with name login.nu has to be in the standard configuration directory.
#
# The file login.nu is sourced after env.nu and config.nu, so that you can overwrite those configurations if you need. There is an environment variable $nu.loginshell-path containing the path to this file.
#
# João V. Farias © BeyondMagic 2024-2026 <beyondmagic@mail.ru>

let xdg_config_home = $env.HOME + '/.config'
let xdg_cache_home = $env.HOME + '/.cache'
let xdg_data_home = $env.HOME + '/.local/share'
let xdg_state_home = $env.HOME + '/.local/state'
let images_folder = '~/storage/images/'

let environment = {
	static: {
		# Path for neovim's last working directory.
		NEOVIM_CD: '/tmp/neovim_cd',

		# For scripts of the desktop.
		DESKTOP_NAME: 'lovemii',

		# XDG folders.
		XDG_CONFIG_HOME: $xdg_config_home,
		XDG_DOWNLOAD_DIR: ($env.HOME + '/armazenamento/baixados'),
		XDG_DESKTOP_DIR: ($env.HOME + '/armazenamento/desktop'),
		XDG_DATA_HOME: $xdg_data_home,
		XDG_CACHE_HOME: $xdg_cache_home,
		XDG_STATE_HOME: $xdg_state_home,

		# Rust: package manager home and configuration.
		CARGO_HOME: ($xdg_config_home + '/cargo'),

		# Bun: home and configuration files.
		BUN_INSTALL: ($xdg_config_home + '/bun'),

		# Activate fcitx5.
		#GTK_IM_MODULE: 'fcitx'
		QT_IM_MODULE: 'fcitx',
		GLFW_IM_MODULE: 'ibus',
		XMODIFIERS: '@im=fcitx',
		GTK_USE_PORTAL: 1,

		# History path for less.
		LESSHISTFILE: '/dev/null',

		# Supress accessibility warning from GNOME bus.
		NO_AT_BRIDGE: 1,

		# Default applications.
		EDITOR: 'nvim',
		VISUAL: 'nvim',
		FILE: 'nnn',
		READER: 'foliate',
		BROWSER: 'firefox-nightly',

		# Scale for Wayland (GTK)
		GDK_SCALE: 1,

		# DPI Scale for Wayland (GTK)
		GDK_DPI_SCALE: 1,

		# Enable Wayland for Firefox.
		MOZ_ENABLE_WAYLAND: 1,
		MOZ_DBUS_REMOTE: 1,

		# Fix all Java issues.
		_JAVA_AWT_WM_NONREPARENTING: 1,

		# Import SSH auth socket.
		SSH_AUTH_SOCK: '/tmp/ssh-agent.socket',

		# For Neovim MRU plugin (latest files).
		MRU_File: ($env.HOME + '/.cache/vim_mru_files'),

		# Python: MYPY cache directory.
		MYPY_CACHE_DIR: ($xdg_cache_home + '/mypy/'),

		# To put trash files in here instead of removing them out of existence.
		TRASH: ($env.HOME + '/.local/trash'),

		# Paru: AUR package manager configuration.
		PARU_CONF: ($xdg_config_home + '/paru/paru.conf'),

		# Possible fix for Steam
		QT_QPA_PLATFORM: 'wayland;xcb',

		# Render GDK for wayland! Useful for ags.
		GDK_BACKEND: 'wayland',

		# Language unix settings.
		LC_TIME: 'ja_JP.UTF-8',
		LANG: 'en_GB.UTF-8',
		LC_COLLATE: 'C.UTF-8',

		# Image folder.
		IMAGES_FOLDER: $images_folder,

		# Default location for images.
		IMAGE_LOCATIONS: ([
			($images_folder + 'extensions/jpg')
			($images_folder + 'extensions/png')
			($images_folder + 'art/extensions/jpg')
			($images_folder + 'art/extensions/png')
			($images_folder + 'art/poetry')
			($images_folder + 'art/gl')
			($images_folder + 'art/flags')
			($images_folder + 'art/design')
			($images_folder + 'photos')
			($images_folder + 'profile/square')
			($images_folder + 'profile/thumbnail')
			($images_folder + 'profile/tall')
		] | str join (char esep)),

		# Glob to all wallpaper files.
		WALLPAPER_FILES: ($images_folder + 'wallpaper/desktop/**/*'),

		# Share local database between diferent personal systems.
		# Useful for sioyek.
		PDF_USER_DATABASE: 'hana',

		# Python: path of './.python_history'.
		PYTHON_HISTORY: ($xdg_data_home + '/python/history.txt'),

		# Python: startup file for Python.
		PYTHONSTARTUP: ($xdg_config_home + '/python/startup.py'),

		# Go path for binaries, etc.
		GOPATH: ($env.HOME + '/.config/go'),

		# For gnupg configuration files.
		GNUPGHOME: ($xdg_config_home + '/gnupg'),

		# Path for .NET SDK runtime packs.
		DBTOOLS_HOME: ($xdg_cache_home + '/dbtools'),

		# Path for .NET SDK runtime packs.
		DOTNET_ROOT: ($xdg_cache_home + '/dotnet'),

		# Path for Docker certificates and config files.
		DOCKER_CERT_PATH: ($xdg_config_home + '/docker/'),

		# Java: user home for Java configuration files.
		_JAVA_OPTIONS: ([
			$'-Djava.util.prefs.userRoot="($xdg_config_home)/java"'
			$'-Djavafx.cachedir="($xdg_cache_home)/openjfx"'
		] | str join (char space)),

		JAVA_HOME: '/usr/lib/jvm/java-17-openjdk/',

		# NPM: Node.js package manager home and configuration.
		NPM_CONFIG_USERCONFIG: ($xdg_config_home + '/npm/npmrc'),

		# OPAM: OCaml package manager home and configuration.
		OPAMROOT: ($xdg_config_home + '/opam'),

		# WINE: configuration files.
		WINEPREFIX: ($xdg_config_home + '/wine/default'),

		# Elixir: package manager home and configuration.
		MIX_XDG: 'true',

		# Oracle SQL Developer: configuration files.
		IDE_USER_DIR: ($xdg_cache_home + '/sqldeveloper/'),

		# GTK 2.0: configuration files.
		GTK2_RC_FILES: ([
			($xdg_config_home + '/gtk-2.0/gtkrc-2.0')
			($xdg_config_home + '/gtk-2.0/gtkrc.mine')
		] | str join (char esep)),

		# WDM: configuration files.
		WDM_DIR: ($xdg_config_home + '/wdm/'),

		# Lean: home and configuration.
		ELAN_HOME: ($xdg_config_home + '/elan/'),

		# OpenSSL: random seed file.
		RANDFILE: ($xdg_cache_home + '/openssl/.rnd'),

		# Claude: AI CLI tool configuration.
		CLAUDE_CONFIG_DIR: ($xdg_config_home + '/claude'),

		# Junie: AI CLI cache folder.
		EJ_FOLDER_WORK: ($xdg_cache_home + '/junie/'),

		# Gradle: configuration files.
		GRADLE_USER_HOME: ($xdg_config_home + '/gradle/'),

		# Kotlin: configuration files.
		KOTLIN_HOME: ($xdg_config_home + '/kotlin/'),
	}

	runtime: {
		# SSH: dynamic get the agent PID.
		SSH_AGENT_PID: (^pidof ssh-agent | complete | get stdout | str trim),

		# Link user binaries.
		# By putting these new binary folders, they end up having higher priority.
		PATH: ((($env.PATH | split row (char esep)) ++ [
			# User's local binaries.
			($env.HOME + '/.local/bin/')
			# Rust: binaries of cargo, package manager.
			($xdg_config_home + '/cargo/bin/')
			# Python: binaries of virtual environment.
			# Bun: binaries.
			($xdg_config_home + '/bun/bin/')
			# Go: binaries.
			($env.HOME + '/.config/go/bin/')
		]) | str join (char esep)),
	}
}

load-env $environment.static
load-env $environment.runtime

# For QT applications, disable GPU usage if Intel CPU is detected.
if (sys cpu | get brand | any { $in =~ 'Intel' }) {
	$env.QTWEBENGINE_CHROMIUM_FLAGS = "--use-gl=disabled"
}
