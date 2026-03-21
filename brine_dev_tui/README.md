# Brine Launcher

A terminal UI for launching the development tools used in the Brine project. Instead of memorizing and manually running a collection of terminal commands, this tool provides a single interface to start and stop everything you need for local development.

Built with [Go](https://go.dev), [Bubbletea](https://github.com/charmbracelet/bubbletea), and [Lipgloss](https://github.com/charmbracelet/lipgloss).

## Why This Exists

The Brine project involves multiple systems that need to run simultaneously during development: device firmware, a device emulator, a serial monitor, the Flutter mobile app, and the Firebase emulator suite. Remembering the exact commands for each, and running them in the right order, is tedious and error-prone. This launcher centralizes all of that into a single, navigable interface.

## Available Tools

| Tool               | Description                                  |
|--------------------|----------------------------------------------|
| Flash Firmware     | Build and flash firmware to the device       |
| Device Emulator    | Start the device emulator for local testing  |
| Serial Monitor     | Open serial monitor for device output        |
| Flutter App        | Launch the Flutter mobile application        |
| Firebase Emulator  | Start the Firebase local emulator suite      |

## Usage

### Build and Run

```sh
cd brine_dev_tui
go build -o brine-launcher .
./brine-launcher
```

### Controls

| Key          | Action                              |
|--------------|-------------------------------------|
| `↑` / `k`   | Move cursor up                      |
| `↓` / `j`   | Move cursor down                    |
| `Enter` / `Space` | Toggle selected tool (start/stop) |
| `q` / `Ctrl+C`    | Quit                             |

## Architecture

The application follows the [Elm Architecture](https://guide.elm-lang.org/architecture/) via Bubbletea, which separates concerns into model, update, and view.

```
brine_dev_tui/
├── main.go      Entry point. Initializes and runs the Bubbletea program.
├── model.go     Application state and input handling (Update loop).
├── view.go      Renders the interface from current state (View function).
├── tool.go      Tool type definition and the default tool list.
├── styles.go    All Lipgloss visual styles and color palette.
├── go.mod       Go module and dependencies.
└── go.sum       Dependency checksums.
```

## Dependencies

- [Bubbletea](https://github.com/charmbracelet/bubbletea) — Terminal UI framework based on the Elm Architecture.
- [Lipgloss](https://github.com/charmbracelet/lipgloss) — Styling and layout for terminal rendering.
