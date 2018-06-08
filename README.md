Due to [Microsoft's acquisition of GitHub](http://www.tfir.io/microsoft-acquires-github-for-7-5-billion), this repo will be a mirror of the same repo on [GitLab](https://gitlab.com/julian-heng/chunkwm-config). Please do not send any issues or pull request on GitHub as they will be ignored.

# chunkwm and skhd configs
My personal chunkwm and skhd configs and scripts

## Installing
```sh
# Remove previous configs
$ rm -rf "${HOME}/.config/"{chunkwm,skhd}
$ rm -f "${HOME}"/.{chunkwmrc,skhdrc}

# Install configs
$ git clone https://github.com/Julian-Heng/chunkwm-config.git
$ mkdir "${HOME}/.config/"{chunkwm,skhd}
$ cp ./chunkwm-config/chunkwm/* "${HOME}/.config/chunkwm"
$ cp ./chunkwm-config/skhd/skhdrc "${HOME}/.config/skhd"
$ ln -s "${HOME}/.config/chunkwm/chunkwmrc" "${HOME}/.chunkwmrc"
$ ln -s "${HOME}/.config/skhd/skhdrc" "${HOME}/.skhdrc"
$ rm -rf ./chunkwm-config
```

## Keyboard shortcuts
### chunkwm
#### Changing focus
<kbd>alt</kbd> + <kbd>wasd</kbd>

<kbd>alt</kbd> + <kbd>ijkl</kbd>

#### Resize windows

| Action       | Key Combination                                  |
|--------------|--------------------------------------------------|
| Resize left  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> |
| Resize right | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>l</kbd> |
| Resize up    | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>i</kbd> |
| Resize down  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>k</kbd> |
| Equalise     | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>0</kbd> |

#### Move windows
<kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>ijkl</kbd>

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

#### Snap windows

| Action            | Key Combination                                    |
|-------------------|----------------------------------------------------|
| Snap left         | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>a/j</kbd> |
| Snap right        | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>d/l</kbd> |
| Center            | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>s/k</kbd> |
| Maximise          | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>w/i</kbd> |
| Fullscreen        | <kbd>alt</kbd>  + <kbd>f</kbd>                     |
| Native Fullscreen | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>f</kbd>   |

#### Insertion point

| Action        | Key Combination                                  |
|---------------|--------------------------------------------------|
| Insert left   | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>a</kbd> |
| Insert right  | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>d</kbd> |
| Insert down   | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>s</kbd> |
| Insert up     | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>w</kbd> |
| Cancel insert | <kbd>lctrl</kbd> + <kbd>alt</kbd> + <kbd>x</kbd> |

#### Misc

| Action          | Key Combination                                                     |
|-----------------|---------------------------------------------------------------------|
| Change modes    | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>c</kbd>                    |
| Toggle float    | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>space</kbd>                |
| Restart chunkwm | <kbd>lctrl</kbd> + <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>r</kbd> |

### non-chunkwm
#### Show information
##### Description
Uses `osascript` to show information like CPU, memory, battery, etc. The CPU script requires [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp) and [iStats](https://github.com/Chris911/iStats) installed. The song script supports iTunes, Spotify and cmus.

Click [here](chunkwm/scripts/display) to view the script folder

##### Key Combination
<kbd>fn</kbd> + <kbd>lctrl</kbd> + <kbd>num</kbd>

##### Screenshots
<img width="378" height="97" src="screenshots/cpu_notify.png?raw=true"><img width="378" height="97" src="screenshots/mem_notify.png?raw=true">
<img width="378" height="97" src="screenshots/bat_notify.png?raw=true"><img width="378" height="97" src="screenshots/disk_notify.png?raw=true">
<img width="378" height="97" src="screenshots/chunkwm_notify.png?raw=true"><img width="378" height="97" src="screenshots/song_notify.png?raw=true">

```
fn + lctrl - 1 : /path/to/script
fn + lctrl - 2 : /path/to/script
fn + lctrl - 3 : /path/to/script
...
```

#### Opening applications
##### Description
Opens applications. <kbd>fn</kbd> + <kbd>alt</kbd> + <kbd>num</kbd> opens apps on the dock a-la windows taskbar and <kbd>fn</kbd> + <kbd>alt</kbd> + <kbd>alpha</kbd> is customisable by the user.

Note that the config is setup to MY dock layout. To use yours, you're gonna have to edit the `skhdrc` file.

##### Key Combination
<kbd>fn</kbd> + <kbd>alt</kbd> + <kbd>num</kbd>

<kbd>fn</kbd> + <kbd>alt</kbd> + <kbd>alpha</kbd>

```
fn + alt - e : open /home/folder
fn + alt - d : open /downloads/folder
fn + alt - 1 : open "/Applications/Safari.app"
fn + alt - 2 : open "/Applications/FirefoxNightly.app"
fn + alt - 3 : open "/Applications/Notes.app"
fn + alt - 4 : open "/Applications/Photos.app"
...
```

#### Screenshots
##### Description
Due to the selection screenshot only selecting the border of the active window and not the actual window, we would have to make a bash script to disable borders before taking a screenshot.

Click [here](chunkwm/scripts/misc/screenshot) to view the script

##### Key Combination
<kbd>command</kbd> + <kbd>shift</kbd> + <kbd>3</kbd>

<kbd>command</kbd> + <kbd>shift</kbd> + <kbd>4</kbd>

<kbd>command</kbd> + <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>3</kbd>

<kbd>command</kbd> + <kbd>shift</kbd> + <kbd>lctrl</kbd> + <kbd>4</kbd>

```
cmd + shift - 3 : /path/to/screenshot/script --fullscreen
cmd + shift - 4 : /path/to/screenshot/script  --selection
cmd + shift + lctrl - 3 : /path/to/screenshot/script  --fullscreen --clipboard
cmd + shift + lctrl - 4 : /path/to/screenshot/script  --selection --clipboard
```

#### Launch iTerm2
##### Description
Launches iTerm2 using like in i3-wm.

Click [here](chunkwm/scripts/misc/open_iTerm2) to view the script

##### Key Combination
<kbd>alt</kbd> + <kbd>return</kbd>

```
alt - return : /path/to/launch/terminal
```

#### Launch Activity Monitor
##### Description
Launches Activity Monitor like in Windows

##### Key Combination
<kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>esc</kbd>

```
shift + alt - escape : open "/Applications/Utilities/Activity Monitor.app"
```
