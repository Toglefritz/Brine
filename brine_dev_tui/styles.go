// styles.go defines all visual styles for the Brine Dev TUI.
//
// Styles are built with Lipgloss and provide consistent theming
// across the entire interface. Colors are chosen to feel polished
// while remaining readable across common terminal color schemes.
package main

import "github.com/charmbracelet/lipgloss"

// Color palette — a cohesive set of colors for the TUI theme.
var (
	colorPrimary   = lipgloss.Color("#7C9CBF")
	colorAccent    = lipgloss.Color("#E8B87E")
	colorGreen     = lipgloss.Color("#8FBF9F")
	colorDim       = lipgloss.Color("#666666")
	colorSubtle    = lipgloss.Color("#888888")
	colorBorder    = lipgloss.Color("#444444")
	colorHighlight = lipgloss.Color("#2A3A4A")
)

// Layout styles for the main container and sections.
var (
	// appStyle wraps the entire application content with padding.
	appStyle = lipgloss.NewStyle().
			Padding(1, 2)

	// headerStyle renders the application title.
	headerStyle = lipgloss.NewStyle().
			Foreground(colorPrimary).
			Bold(true).
			MarginBottom(1)

	// subtitleStyle renders the subtitle beneath the header.
	subtitleStyle = lipgloss.NewStyle().
			Foreground(colorSubtle).
			MarginBottom(1)

	// footerStyle renders the help text at the bottom.
	footerStyle = lipgloss.NewStyle().
			Foreground(colorDim).
			MarginTop(1)
)

// Tool list item styles.
var (
	// itemStyle is the base style for an unselected tool row.
	itemStyle = lipgloss.NewStyle().
			PaddingLeft(2)

	// selectedItemStyle highlights the currently focused tool row.
	selectedItemStyle = lipgloss.NewStyle().
				PaddingLeft(2).
				Background(colorHighlight)

	// toolNameStyle renders the tool name within a row.
	toolNameStyle = lipgloss.NewStyle().
			Foreground(colorAccent).
			Bold(true)

	// toolDescStyle renders the tool description within a row.
	toolDescStyle = lipgloss.NewStyle().
			Foreground(colorSubtle)

	// statusRunningStyle renders the "running" status badge.
	statusRunningStyle = lipgloss.NewStyle().
				Foreground(colorGreen).
				Bold(true)

	// statusStoppedStyle renders the "stopped" status badge.
	statusStoppedStyle = lipgloss.NewStyle().
				Foreground(colorDim)
)
