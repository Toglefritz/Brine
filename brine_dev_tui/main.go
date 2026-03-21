// Brine Dev TUI: A development environment launcher for the Brine project.
//
// This is the entry point for the terminal UI application. It initializes
// the Bubbletea program and hands off to the TUI model.
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running Brine Dev TUI: %v\n", err)
		os.Exit(1)
	}
}
