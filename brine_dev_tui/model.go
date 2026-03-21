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
	// statusMsg is a short message displayed at the bottom of the tool
	// list, used to confirm a launch or report a problem. It is cleared
	// on the next keypress.
	statusMsg string
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
		// Clear the status message on any keypress so it doesn't linger.
		m.statusMsg = ""

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
			m.launchTool()
		}
	}

	return m, nil
}

// launchTool opens the selected tool in a new Terminal.app window.
// If the tool has no command configured, a status message is shown instead.
func (m *model) launchTool() {
	tool := &m.tools[m.cursor]

	if tool.Command == "" {
		m.statusMsg = tool.Name + " is not configured yet."
		return
	}

	err := launchInTerminal(tool.Name, tool.Command, tool.WorkDir)
	if err != nil {
		m.statusMsg = "Failed to launch " + tool.Name + ": " + err.Error()
		return
	}

	m.statusMsg = tool.Name + " launched in a new terminal window."
}
