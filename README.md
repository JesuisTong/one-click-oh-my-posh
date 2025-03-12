# One-Click Oh My Posh

A quick utility to automatically set up [Oh My Posh](https://ohmyposh.dev/) with a custom theme in Windows and WSL.

## Features

- Zero know setup oh-my-posh
- Same theme in windows and wsl, once you change the theme in windows, it will automatically sync to WSL
- Install Meslo Nerd Font automatically 
- Switch font to Meslo Nerd Font in Windows Terminal automatically
- Intergrade oh-my-posh and oh-my-zsh in WSL

## Requirements

### Windows
- Windows 10/11
- Windows Terminal (recommended)
- Winget package manager

### WSL
- WSL2 distribution

## Installation

> **⚠️ WARNING ⚠️**
>
> Always run Windows setup first before setting up WSL.
> Running the WSL setup without completing Windows setup first will cause configuration issues.

### Windows Setup
```powershell
.\one-click-oh-my-posh.ps1
```

### WSL Setup

1. Make sure you have WSL installed and configured
2. From your WSL terminal, execute:

```bash
$ ./one-click-oh-my-posh-wsl-sync.sh
```

## Theme customization

The default theme is set to a custom theme (`tongz.omp.json`). Switch to any other theme if you want.

## License

This project is open source and available under the MIT License.
