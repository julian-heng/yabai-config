# chunkwm and skhd configs
My personal chunkwm and skhd configs and scripts

See my [dotfiles](https://gitlab.com/julian-heng/dotfiles.git) repo for my other configs

## Installing
```sh
# Remove previous links
$ rm -f "${HOME}"/.{chunkwmrc,skhdrc}

# Install configs
$ git clone https://github.com/Julian-Heng/chunkwm-config.git "${HOME}"/.config/chunkwm
$ ln -s "${HOME}/.config/chunkwm/chunkwmrc" "${HOME}/.chunkwmrc"
$ ln -s "${HOME}/.config/chunkwm/skhdrc" "${HOME}/.skhdrc"
```

## Keyboard shortcuts
### Chunkwm
#### Changing focus
<kbd>alt</kbd> + <kbd>hjkl</kbd>

#### Resize windows

| Action       | Key Combination                                  |
|--------------|--------------------------------------------------|
| Resize left  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>h</kbd> |
| Resize down  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> |
| Resize up    | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>k</kbd> |
| Resize right | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>l</kbd> |
| Equalise     | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>0</kbd> |

#### Move windows
<kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>hjkl</kbd>

#### Move windows to workspace

| Action                      | Key Combination                                    |
|-----------------------------|----------------------------------------------------|
| Send to last active desktop | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>m</kbd>   |
| Send to previous workplace  | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>p</kbd>   |
| Send to next workplace      | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>n</kbd>   |
| Send to workplace           | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>num</kbd> |

#### Rotate windows

| Action               | Key Combination                                  |
|----------------------|--------------------------------------------------|
| Rotate clockwise     | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>r</kbd> |
| Rotate anticlockwise | <kbd>alt</kbd> + <kbd>r</kbd>                    |
| Flip on x-axis       | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>x</kbd> |
| Flip on y-axis       | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>y</kbd> |

#### Window actions

| Action            | Key Combination                                  |
|-------------------|--------------------------------------------------|
| Fullscreen        | <kbd>alt</kbd>  + <kbd>f</kbd>                   |
| Native fullscreen | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>f</kbd> |
| Center window     | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>c</kbd> |

#### Insertion point

| Action        | Key Combination                                  |
|---------------|--------------------------------------------------|
| Insert left   | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>h</kbd> |
| Insert down   | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> |
| Insert up     | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>k</kbd> |
| Insert right  | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>l</kbd> |
| Cancel insert | <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>x</kbd> |

#### Misc

| Action          | Key Combination                                                     |
|-----------------|---------------------------------------------------------------------|
| Toggle float    | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>space</kbd>                |
| Toggle gaps     | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>g</kbd>                    |
| Restart chunkwm | <kbd>lctrl</kbd> + <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>r</kbd> |

### Non-chunkwm
#### Show information
##### Description
Uses `osascript` to show information like CPU, memory, battery, etc. The CPU script requires [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp) installed. The song script supports iTunes and cmus.

Click [here](scripts) to view the script folder

Note: May have to change the location of the scripts in skhdrc

##### Key Combination
<kbd>fn</kbd> + <kbd>lalt</kbd> + <kbd>num</kbd>

##### Screenshots
<img width="382" height="101" src="screenshots/cpu.png?raw=true"><img width="382" height="101" src="screenshots/mem.png?raw=true">
<img width="382" height="101" src="screenshots/bat.png?raw=true"><img width="382" height="101" src="screenshots/disk.png?raw=true">
<img width="382" height="101" src="screenshots/song.png?raw=true">

```
fn + lalt - 1 : /path/to/script
fn + lalt - 2 : /path/to/script
fn + lalt - 3 : /path/to/script
...
```

#### Opening applications
#### Launch iTerm2
##### Description
Launches iTerm2 using like in i3-wm.

Click [here](scripts/open_iterm2.sh) to view the script

##### Key Combination
<kbd>alt</kbd> + <kbd>return</kbd>

```
alt - return : /path/to/launch/terminal
```
