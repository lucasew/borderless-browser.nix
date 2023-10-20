# Borderless Browser

Chromium based browsers such as Google Chrome, Brave and even Chromium (really?) have a feature that you can open websites in full screen windows but without having to hide all the stuff in your desktop. It looks kind of how Electron apps look but without the NodeJS part.

This is a tool to make this feature more user friendly.

## Features
- A dialog using zenity to interactively launch a borderless window.
- Open a borderless window pointing to the first argument.
- Non default profiles, so you can login to your bank or some shady stuff without mixing up things. The profiles are saved in `~/.config/borderless-browser-profiles` by default.
- home-manager module to define webapps in bulk.
- Nix wrapper generator to generate webapps on the fly.
- Standalone script (borderless-browser) to use it standalone in systems that don't have Nix.
