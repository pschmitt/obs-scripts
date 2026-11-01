# Agent guidance

This repository contains Lua scripts for OBS Studio. `utils.lua` is a shared dependency and should not be installed as a script on its own.

## Development

- Keep script settings and behavior aligned with the descriptions in `README.md`.
- If `stylua` is available, check changed Lua files with `stylua --check <files>`.
- Test OBS behavior in a disposable OBS profile; do not rely on a personal profile or machine-specific paths.

## CI

- Before changing CI, inspect the current guidance in `pschmitt/ci-workflows`. Pin shared reusable workflow and action references to `@main`.
