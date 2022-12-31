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

```bash
git clone git@github.com:the-argus/nobar
sudo ln -sf ./nobar/src/nobar /bin/nobar
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
