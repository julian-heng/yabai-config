# Yabai and Skhd Config

This repository contains my standalone Yabai and Skhd configurations.

See my [dotfiles](https://gitlab.com/julian-heng/dotfiles.git) repository for my other configurations.

To see the old Chunkwm configurations, click [here](https://github.com/Julian-Heng/yabai-config/tree/old).

NOTE: Yabai requires System Integrity Protection to be disabled to work properly. See [here](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection) for more information.
NOTE: For macOS Big Sur and above, scripting additions needs elevated privileges to work properly. See [here](<https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#macos-big-sur---automatically-load-scripting-addition-on-startup>) for more information.

## Installation

```sh
# Remove previous links
$ rm -f "${HOME}"/.{yabai,skhd}rc

# Install configs
$ git clone https://github.com/Julian-Heng/yabai-config.git "${HOME}"/.config/yabai
$ ln -s "${HOME}/.config/yabai/yabairc" "${HOME}/.yabairc"
$ ln -s "${HOME}/.config/yabai/skhdrc" "${HOME}/.skhdrc"
```

## Keyboard Shortcuts

### Changing Focus

<kbd>alt</kbd> + <kbd>hjkl</kbd>

### Resize Windows

| Action       | Key Combination                                  |
| ------------ | ------------------------------------------------ |
| Resize left  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>h</kbd> |
| Resize down  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> |
| Resize up    | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>k</kbd> |
| Resize right | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>l</kbd> |
| Equalise     | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>e</kbd> |

### Move Windows

<kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>hjkl</kbd>

### Move Windows to Workspace

| Action                      | Key Combination                                    |
| --------------------------- | -------------------------------------------------- |
| Send to last active desktop | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>m</kbd>   |
| Send to previous workplace  | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>p</kbd>   |
| Send to next workplace      | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>n</kbd>   |
| Send to workplace           | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>num</kbd> |

### Rotate Windows

| Action               | Key Combination                                  |
| -------------------- | ------------------------------------------------ |
| Rotate clockwise     | <kbd>alt</kbd> + <kbd>r</kbd>                    |
| Rotate anticlockwise | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>r</kbd> |
| Flip on x-axis       | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>x</kbd> |
| Flip on y-axis       | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>y</kbd> |

### Window Actions

| Action            | Key Combination                                  |
| ----------------- | ------------------------------------------------ |
| Fullscreen        | <kbd>alt</kbd> + <kbd>f</kbd>                    |
| Native fullscreen | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>f</kbd> |

### Window Insertion Point

| Action       | Key Combination                                                     |
| ------------ | ------------------------------------------------------------------- |
| Insert left  | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>h</kbd> |
| Insert down  | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> |
| Insert up    | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>k</kbd> |
| Insert right | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>l</kbd> |

NOTE: To cancel insertion point, press the last inerstion key combination.

### Misc

| Action        | Key Combination                                                     |
| ------------- | ------------------------------------------------------------------- |
| Toggle float  | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>space</kbd>                |
| Toggle gaps   | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>g</kbd>                    |
| Restart yabai | <kbd>lctrl</kbd> + <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>r</kbd> |

### Showing System Information

#### Description

Uses `osascript` to show information like CPU, memory, battery, etc. The CPU script requires [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp) installed. The song script supports Spotify, Music and cmus.

Click [here](scripts) to view the script folder.

NOTE: May have to change the location of the scripts in skhdrc.

#### Key Combination

<kbd>fn</kbd> + <kbd>lalt</kbd> + <kbd>num</kbd>

#### Screenshots

<img width="370" height="120" src="screenshots/cpu.png?raw=true"><img width="370" height="120" src="screenshots/mem.png?raw=true">
<img width="370" height="120" src="screenshots/bat.png?raw=true"><img width="370" height="120" src="screenshots/disk.png?raw=true">
<img width="370" height="120" src="screenshots/song.png?raw=true">

```
fn + lalt - 1 : /path/to/script
fn + lalt - 2 : /path/to/script
fn + lalt - 3 : /path/to/script
...
```

### Launch iTerm2

#### Description

Launches iTerm2.

Click [here](scripts/open_iterm2.sh) to view the script.

#### Key Combination

<kbd>alt</kbd> + <kbd>return</kbd>

```
alt - return : /path/to/launch/terminal
```
