// tool.go defines the Tool type representing a launchable development tool.
//
// Each tool has a display name, description, and a status indicating
// whether it is currently running or stopped.
package main

// Status represents the current state of a development tool.
type Status int

const (
	// Stopped indicates the tool is not currently running.
	Stopped Status = iota
	// Running indicates the tool is actively running.
	Running
)

// String returns a human-readable label for the status.
func (s Status) String() string {
	switch s {
	case Running:
		return "running"
	default:
		return "stopped"
	}
}

// Tool represents a single development tool that can be launched
// from the TUI. It holds display metadata and runtime state.
type Tool struct {
	// Name is the display label shown in the tool list.
	Name string
	// Description is a short explanation of what the tool does.
	Description string
	// Status tracks whether the tool is currently running or stopped.
	Status Status
}

// defaultTools returns the initial set of development tools available
// in the launcher. Commands will be wired up in a later iteration.
func defaultTools() []Tool {
	return []Tool{
		{
			Name:        "Flash Firmware",
			Description: "Build and flash firmware to the device",
		},
		{
			Name:        "Device Emulator",
			Description: "Start the device emulator for local testing",
		},
		{
			Name:        "Serial Monitor",
			Description: "Open serial monitor for device output",
		},
		{
			Name:        "Flutter App",
			Description: "Launch the Flutter mobile application",
		},
		{
			Name:        "Firebase Emulator",
			Description: "Start the Firebase local emulator suite",
		},
	}
}
