# nobar

An alternative workflow for tiling window managers, created by removing the bar.

## Window manager support

Currently supported:

- I3

Planned support:

- Sway
- BSPWM

## Installation

How to install nobar. First, you need to correctly install the ``nobar``
executable (found in the ``src/`` folder) and then you can make your window
manager's keybinds invoke it by name. Alternatively, you can skip this step and
instead just clone this git repository and refer to the exectutable by absolute
path.

### Using nix and flakes (recommended)

This is definitely the best way to install nobar, but unforunately a lot of
documentation is obtuse or somewhat out of date, so I don't have an resources
to provide to anyone who does not already have a working home-manager install
and a configuration flake. If you dont, see the [non-nix install guide](#non-nix)

First, back up your window manager config. I3 will be used as the example in
this guide.

```bash
mv ~/.config/i3/config ~/.config/i3/config.backup
```

Then, add this flake to your configuration flake's inputs:

```nix
{
    inputs = {
        # other inputs up here
        
        # your preferred home-manager release
        home-manager.url = github:nix-community/home-manager/release-22.11;

        nobar.url = github:the-argus/nobar;
    };
}
```

And add its module to your homeConfigurations:

```nix
{
    outputs = {
        home-manager,
        nobar
    } : {
        homeConfigurations = {
            "${argus}" = home-manager.lib.homeManagerConfiguration {
                # other home-manager configuration options....

                modules = [ nobar.homeManagerModule ];
            };
        };
    };
}
```

Then, see [the home manager module doc](./module.md) for information on how to
configure nobar to your liking.

Finally, update and apply your flake:

```bash
nix flake update
home-manager switch --flake .
```

### Non-nix

If you're not using nix, run the following:
(please use nix... this approach makes me want to die)

```bash
git clone git@github.com:the-argus/nobar
sudo ln -sf ./nobar/src/nobar /bin/nobar
sudo ln -sf ./nobar/src/sh/mem-gb /bin/nobar
sudo ln -sf ./nobar/src/sh/monitor-album-art /bin/nobar
sudo ln -sf ./nobar/src/py/bring-to /bin/nobar
sudo ln -sf ./nobar/src/py/isolate /bin/nobar
sudo ln -sf ./nobar/src/py/window-switcher /bin/nobar
sudo mkdir -p /lib/python3.10/site-packages
sudo ln -sf ./nobar/src/py/nobar /lib/python3.10/site-packages/
```

Then, you need to make sure you have the following dependencies installed:

- python 3.10
- eww
- playerctl
- rofi

Finally, you need to make sure that running ``python --version`` yields some
3.10 version, and that you have the ``i3ipc`` python package installed
for that version of python. ``pip install i3ipc`` should work.

If ``python --version`` yields a python 2 version number, then you can modify
the scripts in this repository (located at ``./src/py/``) to refer to
``python3`` instead of of ``python`` in their shebangs.

## Usage

After installation, the command ``nobar`` should be available in your path.
The following are available subcommands:

- add

Usage: ``nobar add [widget]``
Makes a certain widget visible on your screen. Currently available widgets are
``time``, ``playerctl``, and ``system-stats``.

- remove

Usage: ``nobar remove [widget]``
Removes a widget from the screen. See above for available widgets.

- isolate

Usage: ``nobar isolate``
Takes the currently focused window and moves it to the next available empty
workspace.

- window-switcher

Usage: ``nobar window-switcher``
Opens a rofi menu from which other open windows (so not the focused window) can
be chosen.

- bring-to

Usage: ``nobar bring-to``
Opens a similar menu to ``window-switcher``. However, when one of these windows
is selected, it will bring the currently focused window to the same workspace as
the selected window.
