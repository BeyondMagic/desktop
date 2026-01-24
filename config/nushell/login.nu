# Nushell Environment Login File
#
# Configuration with login.nu
#
# If Nushell is used as a login shell, you can use a specific configuration file which is only sourced in this case. Therefore a file with name login.nu has to be in the standard configuration directory.
#
# The file login.nu is sourced after env.nu and config.nu, so that you can overwrite those configurations if you need. There is an environment variable $nu.loginshell-path containing the path to this file.
#
# João V. Farias © BeyondMagic 2024-2026 <beyondmagic@mail.ru>

# Path for neovim's last working directory.
$env.NEOVIM_CD = '/tmp/neovim_cd'

# For scripts of the desktop.
$env.DESKTOP_NAME = 'lovemii'

# XDG default folder for configuration files.
$env.XDG_CONFIG_HOME = $env.HOME + '/.config'

$env.XDG_DOWNLOAD_DIR = $env.HOME + '/armazenamento/baixados'

# Rust: package manager home and configuration.
$env.CARGO_HOME = $env.XDG_CONFIG_HOME + '/cargo'

# Bun: home and configuration files.
$env.BUN_INSTALL = $env.XDG_CONFIG_HOME + '/bun'

# Activate fcitx5.
#$env.GTK_IM_MODULE = fcitx
$env.QT_IM_MODULE = 'fcitx'
$env.GLFW_IM_MODULE = 'ibus'
$env.XMODIFIERS = '@im=fcitx'
$env.GTK_USE_PORTAL = 1

# History path for less.
$env.LESSHISTFILE = '/dev/null'

# Supress accessibility warning from GNOME bus.
$env.NO_AT_BRIDGE = 1

# Default text editor.
$env.EDITOR = 'nvim'

# Default visual editor.
$env.VISUAL = 'nvim'

# Default application for file manager.
$env.FILE = 'nnn'

# Default application for reading files.
$env.READER = 'foliate'

# Default application for browser.
$env.BROWSER = 'firefox-nightly'

# Scale for Wayland (GTK)
$env.GDK_SCALE = 1

# DPI Scale for Wayland (GTK)
$env.GDK_DPI_SCALE = 1

# Enable Wayland for Firefox.
$env.MOZ_ENABLE_WAYLAND = 1
$env.MOZ_DBUS_REMOTE = 1

# Fix all Java issues.
$env._JAVA_AWT_WM_NONREPARENTING = 1

# Import SSH auth socket.
$env.SSH_AUTH_SOCK = '/tmp/ssh-agent.socket'

# For Neovim MRU plugin (latest files).
$env.MRU_File = $env.HOME + '/.cache/vim_mru_files'

# XDG desktop folder.
$env.XDG_DESKTOP_DIR = $env.HOME + '/armazenamento/desktop'

# XDG default folder for data files.
$env.XDG_DATA_HOME = $env.HOME + '/.local/share'

# XDG cache folder.
$env.XDG_CACHE_HOME = $env.HOME + '/.cache'

# XDG state folder.
$env.XDG_STATE_HOME = $env.HOME + '/.local/state'

# Python: MYPY cache directory.
$env.MYPY_CACHE_DIR = $env.XDG_CACHE_HOME + '/mypy/'

# To put trash files in here instead of removing them out of existence.
$env.TRASH = $env.HOME + '/.local/trash'

# Paru: AUR package manager configuration.
$env.PARU_CONF = $env.XDG_CONFIG_HOME + '/paru/paru.conf'

# Possible fix for Steam
$env.QT_QPA_PLATFORM = 'wayland;xcb'

# Render GDK for wayland! Useful for ags.
$env.GDK_BACKEND = 'wayland'

# Language unix settings.
$env.LC_TIME = 'ja_JP.UTF-8'
$env.LANG = 'en_GB.UTF-8'
$env.LC_COLLATE = 'C.UTF-8'

# Image folder.
$env.IMAGES_FOLDER = '~/storage/images/'

# Default location for images.
$env.IMAGE_LOCATIONS = [
	($env.IMAGES_FOLDER + 'extensions/jpg')
	($env.IMAGES_FOLDER + 'extensions/png')
	($env.IMAGES_FOLDER + 'art/extensions/jpg')
	($env.IMAGES_FOLDER + 'art/extensions/png')
	($env.IMAGES_FOLDER + 'art/poetry')
	($env.IMAGES_FOLDER + 'art/gl')
	($env.IMAGES_FOLDER + 'art/flags')
	($env.IMAGES_FOLDER + 'art/design')
	($env.IMAGES_FOLDER + 'photos')
	($env.IMAGES_FOLDER + 'profile/square')
	($env.IMAGES_FOLDER + 'profile/thumbnail')
	($env.IMAGES_FOLDER + 'profile/tall')
] | str join (char esep)

# Glob to all wallpaper files.
$env.WALLPAPER_FILES = $env.IMAGES_FOLDER + 'wallpaper/desktop/**/*'

# Share local database between diferent personal systems.
# Useful for sioyek.
$env.PDF_USER_DATABASE = 'hana'

# Python: path of './.python_history':
$env.PYTHON_HISTORY = $env.XDG_DATA_HOME + '/python/history.txt'

# Python: startup file for Python.
$env.PYTHONSTARTUP = $env.XDG_CONFIG_HOME + '/python/startup.py'

# Runit: directory for serive manager (sv).
$env.SVDIR =  $env.HOME + '/.local/services'

# SSH: dynamic get the agent PID.
$env.SSH_AGENT_PID = ^pidof ssh-agent | complete | get stdout | str trim

# Go path for binaries, etc.
$env.GOPATH = $env.HOME + '/.config/go'

# Link user binaries.
# By putting these new binary folders, they end up having higher priority.
$env.PATH = ($env.PATH | split row (char esep)) ++ [
	# User's local binaries.
	($env.HOME + '/.local/bin/')
	# Rust: binaries of cargo, package manager.
	($env.CARGO_HOME + '/bin/')
	# Python: binaries of virtual environment.
	# Bun: binaries.
	($env.BUN_INSTALL + '/bin/')
	# Go: binaries.
	($env.GOPATH + '/bin/')
] | str join (char esep)

# For QT applications, disable GPU usage if Intel CPU is detected.
if (sys cpu | get brand | any { $in =~ 'Intel' }) {
	$env.QTWEBENGINE_CHROMIUM_FLAGS = "--use-gl=disabled"
}

# For gnupg configuration files.
$env.GNUPGHOME = $env.XDG_CONFIG_HOME + '/gnupg'

# Path for .NET SDK runtime packs.
$env.DBTOOLS_HOME = $env.XDG_CACHE_HOME + '/dbtools'

# Path for .NET SDK runtime packs.
$env.DOTNET_ROOT = $env.XDG_CACHE_HOME + '/dotnet'

# Path for Docker certificates and config files.
$env.DOCKER_CERT_PATH = $env.XDG_CONFIG_HOME + '/docker/'

# Java: user home for Java configuration files.
$env._JAVA_OPTIONS = [
  $'-Djava.util.prefs.userRoot="($env.XDG_CONFIG_HOME)/java"'
  $'-Djavafx.cachedir="($env.XDG_CACHE_HOME)/openjfx"'
] | str join (char space)

$env.JAVA_HOME = '/usr/lib/jvm/java-17-openjdk/'

# NPM: Node.js package manager home and configuration.
$env.NPM_CONFIG_USERCONFIG = $env.XDG_CONFIG_HOME + '/npm/npmrc'

# OPAM: OCaml package manager home and configuration.
$env.OPAMROOT = $env.XDG_CONFIG_HOME + '/opam'

# WINE: configuration files.
$env.WINEPREFIX = $env.XDG_CONFIG_HOME + '/wine/default'

# Elixir: package manager home and configuration.
$env.MIX_XDG = 'true'

# Oracle SQL Developer: configuration files.
$env.IDE_USER_DIR = $env.XDG_CACHE_HOME + '/sqldeveloper/'

# GTK 2.0: configuration files.
$env.GTK2_RC_FILES = [
  $env.XDG_CONFIG_HOME + '/gtk-2.0/gtkrc-2.0'
  $env.XDG_CONFIG_HOME + '/gtk-2.0/gtkrc.mine'
] | str join (char esep)

# WDM: configuration files.
$env.WDM_DIR = $env.XDG_CONFIG_HOME + '/wdm/'

# Lean: home and configuration.
$env.ELAN_HOME = $env.XDG_CONFIG_HOME + '/elan/'

# OpenSSL: random seed file.
$env.RANDFILE = $env.XDG_CACHE_HOME + '/openssl/.rnd'

# Claude: AI CLI tool configuration.
$env.CLAUDE_CONFIG_DIR = $env.XDG_CONFIG_HOME + '/claude'

# Junie: AI CLI cache folder.
$env.EJ_FOLDER_WORK = $env.XDG_CACHE_HOME + '/junie/'

# Gradle: configuration files.
$env.GRADLE_USER_HOME = $env.XDG_CONFIG_HOME + '/gradle/'

# Kotlin: configuration files.
$env.KOTLIN_HOME = $env.XDG_CONFIG_HOME + '/kotlin/'
