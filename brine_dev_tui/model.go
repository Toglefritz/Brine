// model.go contains the Bubbletea model, which contains the core 
// state and logic for the Brine Dev TUI application.
package main

import tea "github.com/charmbracelet/bubbletea"

// model holds the entire application state for the TUI.
type model struct {
	// tools is the list of development tools available to launch.
	tools []Tool
	// cursor tracks which tool is currently highlighted.
	cursor int
}

// initialModel creates the starting state for the application.
func initialModel() model {
	return model{
		tools: defaultTools(),
	}
}

// Init satisfies the Bubbletea Model interface. No initial commands needed.
func (m model) Init() tea.Cmd {
	return nil
}

// Update handles incoming messages (keypresses, window events, etc.)
// and returns the updated model and any commands to execute.
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c":
			return m, tea.Quit

		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}

		case "down", "j":
			if m.cursor < len(m.tools)-1 {
				m.cursor++
			}

		case "enter", " ":
			m.toggleTool()
		}
	}

	return m, nil
}

// toggleTool switches the status of the currently selected tool
// between Running and Stopped.
func (m *model) toggleTool() {
	tool := &m.tools[m.cursor]
	if tool.Status == Running {
		tool.Status = Stopped
	} else {
		tool.Status = Running
	}
}
