// view.go renders the TUI interface. All visual output is assembled
// here using Lipgloss styles defined in styles.go.
package main

import "fmt"

// View renders the current model state as a styled string for display.
// This satisfies the Bubbletea Model interface.
func (m model) View() string {
	// Header
	header := headerStyle.Render("🧂 Brine Launcher")
	subtitle := subtitleStyle.Render("Development Environment Tools")

	// Tool list
	list := ""
	for i, tool := range m.tools {
		list += renderToolRow(i, tool, m.cursor) + "\n"
	}

	// Footer help
	footer := footerStyle.Render("↑/↓ navigate • enter toggle • q quit")

	return appStyle.Render(
		header + "\n" +
			subtitle + "\n\n" +
			list + "\n" +
			footer,
	)
}

// renderToolRow builds a single styled row for a tool in the list.
func renderToolRow(index int, tool Tool, cursor int) string {
	// Status badge
	var status string
	if tool.Status == Running {
		status = statusRunningStyle.Render("● running")
	} else {
		status = statusStoppedStyle.Render("○ stopped")
	}

	// Cursor indicator
	cursor_indicator := "  "
	if index == cursor {
		cursor_indicator = "▸ "
	}

	// Tool name and description
	name := toolNameStyle.Render(tool.Name)
	desc := toolDescStyle.Render(tool.Description)

	row := fmt.Sprintf("%s%s  %s\n   %s", cursor_indicator, name, status, desc)

	// Apply row-level styling based on selection
	if index == cursor {
		return selectedItemStyle.Render(row)
	}
	return itemStyle.Render(row)
}
