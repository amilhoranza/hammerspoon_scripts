# Hammerspoon Scripts

A collection of Hammerspoon scripts for macOS window management and productivity enhancements.

## What is Hammerspoon?

[Hammerspoon](https://www.hammerspoon.org/) is a powerful automation tool for macOS that allows you to write Lua scripts to control your system.

## Features

This configuration includes several Spoons (Hammerspoon plugins):

### ShortcutCheatSheet

Um Spoon para Hammerspoon que exibe uma folha de atalhos (cheat sheet) para o ShiftIt e outros atalhos do sistema.

## Características

- Exibe uma janela flutuante com todos os atalhos do ShiftIt
- Interface limpa e moderna com fundo semi-transparente
- Suporte para teclas especiais do macOS (⌃, ⌥, ⌘)
- Fecha automaticamente com a tecla ESC ou ao pressionar o atalho novamente
- Totalmente personalizável através do código

### ShiftIt

A powerful window management system inspired by the original ShiftIt app. All shortcuts use the modifier combination `ctrl + alt + cmd`.

#### Window Management Shortcuts

| Shortcut | Action                              |
| -------- | ----------------------------------- |
| `left`   | Move window to left half            |
| `right`  | Move window to right half           |
| `up`     | Move window to top half             |
| `down`   | Move window to bottom half          |
| `1`      | Move window to top-left quarter     |
| `2`      | Move window to top-right quarter    |
| `3`      | Move window to bottom-left quarter  |
| `4`      | Move window to bottom-right quarter |
| `m`      | Maximize window                     |
| `f`      | Toggle full screen                  |
| `z`      | Toggle zoom                         |
| `c`      | Center window                       |
| `n`      | Move to next screen                 |
| `p`      | Move to previous screen             |
| `=`      | Resize window out                   |
| `-`      | Resize window in                    |
| `a`      | Arrange windows in 4 quarters       |
| `t`      | Arrange windows in 3 columns        |

### FinderEnhancer

Automatically brings all Finder windows to front when switching to Finder application.

### CaffeineMenu

Prevents your Mac from going to sleep. Adds a AWAKE/SLEEPY button to the menu bar that you can click to toggle.

### ConfigReloader

Automatically reloads your Hammerspoon configuration when changes are detected.

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/)
2. Clone this repository:

```bash
git clone https://github.com/amilhoranza/hammerspoon_scripts.git ~/.hammerspoon
```

## Structure

```
~/.hammerspoon/
├── init.lua           # Main configuration file
└── Spoons/           # Spoons directory
    ├── FinderEnhancer.spoon/
    ├── CaffeineMenu.spoon/
    ├── ConfigReloader.spoon/
    ├── ShiftIt.spoon/
    └── ShortcutCheatSheet.spoon/
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License.
