# 🎬 OBS Scripts Collection by pschmitt 🌟

Welcome to my collection of personal OBS Lua Scripts!

These scripts are a curated set of tools I've developed to enhance my OBS-Studio
setup. They automate routine tasks, add functionality, and seamlessly integrate
custom shell commands.

## 📖 Details

### 🛠️ `utils.lua`

A set of core utility functions supporting the functionality of other scripts.
This file *should not* be installed directly in OBS.

### 📝 `cmd-to-text.lua`

Executes shell commands and updates an OBS text source with the results.

Parameters:

  - `interval`: Time interval in seconds between command executions.
  - `timeout`: Timeout in seconds for the shell command.
  - `command`: The shell command to execute.
  - `shell`: Shell environment to use (default: `sh`).
  - `target_source`: OBS text source to be updated.

### ⏲️ `timetracking.lua`

This is an example script showcasing how to extend `cmd-to-text.lua` for
specific tasks like displaying time tracking information from Taskwarrior and
changing the color of the target source based on the output.

Parameters:

  - `interval`, `timeout`, `command`, `shell`, `target_source`: Similar to `cmd-to-text.lua`.

## 🏐 `bounce.lua`

This my fork of [obs-bounce](https://github.com/insin/obs-bounce), which brings
a few quality-of-life improvements.

See [the PR](https://github.com/insin/obs-bounce/pull/8) for more details.

## 🛠️ Installation

1. Clone the repository to obtain all scripts, along with necessary
dependencies such as `utils.lua`:
   ```shell
   git clone --recursive https://github.com/pschmitt/obs-scripts \
     ~/.config/obs-studio/scripts/obs-scripts.git
   ```
2. In OBS, go to `Tools` > `Scripts`.
3. Click the `+` button and add the desired Lua scripts, excluding `utils.lua`,
which acts as a dependency and doesn't need to be directly loaded into OBS.

## 📜 License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
For more detailed information, refer to the [LICENSE](LICENSE) file in this repository.
