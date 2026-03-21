// launch.go opens a new Terminal.app window and runs a command in it.
//
// This uses macOS osascript to create a named terminal window so each
// development tool gets its own visible session. The TUI stays
// responsive in the original window while the tool runs independently.
package main

import (
	"fmt"
	"os/exec"
)

// launchInTerminal opens a new Terminal.app window with the given title
// and runs the specified command in the provided working directory.
//
// The terminal window stays open after the command finishes so the user
// can review output. If workDir is empty, the command runs in the
// current directory.
func launchInTerminal(title string, command string, workDir string) error {
	// Build the shell command that will run inside the new terminal.
	// The cd is included so the command executes in the right directory.
	shellCommand := command
	if workDir != "" {
		shellCommand = fmt.Sprintf("cd %q && %s", workDir, command)
	}

	// AppleScript that tells Terminal.app to open a new window, set its
	// title, and execute the command. The custom title setting uses a
	// Terminal.app property that overrides the default tab/window name.
	script := fmt.Sprintf(`
		tell application "Terminal"
			activate
			set newWindow to do script %q
			set custom title of tab 1 of window 1 to %q
		end tell
	`, shellCommand, title)

	return exec.Command("osascript", "-e", script).Run()
}
