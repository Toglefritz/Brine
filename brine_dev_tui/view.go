// view.go renders the TUI interface. All visual output is assembled
// here using Lipgloss styles defined in styles.go.
package main

import "fmt"

// View renders the current model state as a styled string for display.
// This satisfies the Bubbletea Model interface.
func (m model) View() string {
	header := headerStyle.Render("🧂 Brine Launcher")
	subtitle := subtitleStyle.Render("Development Environment Tools")

	list := ""
	for i, tool := range m.tools {
		list += renderToolRow(i, tool, m.cursor) + "\n"
	}

	// Show the status message when present (launch confirmation, errors, etc.)
	status := ""
	if m.statusMsg != "" {
		status = "\n" + statusMsgStyle.Render(m.statusMsg)
	}

	footer := footerStyle.Render("↑/↓ navigate • enter launch • q quit")

	return appStyle.Render(
		header + "\n" +
			subtitle + "\n\n" +
			list +
			status + "\n" +
			footer,
	)
}

// renderToolRow builds a single styled row for a tool in the list.
func renderToolRow(index int, tool Tool, cursor int) string {
	cursorIndicator := "  "
	if index == cursor {
		cursorIndicator = "▸ "
	}

	name := toolNameStyle.Render(tool.Name)
	desc := toolDescStyle.Render(tool.Description)

	// Show a dim "not configured" note for tools without a command yet.
	configured := ""
	if tool.Command == "" {
		configured = statusStoppedStyle.Render("  (not configured)")
	}

	row := fmt.Sprintf("%s%s%s\n   %s", cursorIndicator, name, configured, desc)

	if index == cursor {
		return selectedItemStyle.Render(row)
	}
	return itemStyle.Render(row)
}
