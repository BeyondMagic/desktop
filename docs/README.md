**lovemii**: A **very personal** nushell-driven dotfiles collection to configure a personalized desktop environment (Hyprland, apps, services) for fast, reproducible setup.

# Requirements

- A linux distribution with dinit as init system and pacman as package manager.
- Intermediate knowledge of unix-like systems and desktop environments.
- Basic knowledge of git.

# Setup

## Configuration

You can find explanations for each option inside the `config.example.toml` file. You should read and make a copy of this file named `config.toml` and edit it to your needs before running the setup.

## Quickstart

1. Install [nushell](https://www.nushell.sh/), then run the following:

```sh
$ git clone https://github.com/BeyondMagic/desktop ~/projects/desktop
$ cd ~/projects/desktop
```

2. Extend the `sys` module:
```sh
$ use sys.nu
```

3. Read and understand the `sys` module:
```sh
$ sys --help
```

4. Copy the example configuration file and edit it to your needs:
```sh
$ cp config.example.toml config.toml
```

5. Open the configuration file and run the setup function, which will install and configure everything interactively:
```sh
$ open config.toml | sys setup
```

## Usage

After the setup is complete, you can use the `sys` command to manage your desktop environment.

- To update your configuration, run:
```sh
$ sys update
```

<!-- - To backup your current configuration, run:
```sh
$ sys backup | save restore_point.toml
``` -->

<!-- - To restore a previous configuration, run:
```sh
$ open restore_point.toml | sys restore
``` -->

# Troubleshooting

If you encounter any issues during the setup or usage of this project, please refer to the [Issues](https://github.com/BeyondMagic/desktop/issues) section of the repository. You can also open a new issue if your problem is not listed.

# Principles

1. `lovemii` is, generally speaking, multipurposed. It includes features which you *really* need to set up a desktop environment, but also features which are *nice to have*.

2. `lovemii` is designed to be as modular as possible. You can enable or disable features in the configuration file.

3. User experience is a priority, second only to performance. The setup process is interactive and guides you through the configuration.

# Contributing

Contribution [guidelines](/CONTRIBUTING.md).

# License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](/LICENSE) file for details.

Maintained solely by [beyondmagic](https://github.com/beyondmagic).