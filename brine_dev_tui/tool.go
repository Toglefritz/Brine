// tool.go defines the Tool type representing a launchable development tool.
//
// Each tool has a display name, description, and the shell command
// that gets executed in a new Terminal.app window when launched.
package main

// Tool represents a single development tool that can be launched
// from the TUI. It holds display metadata and the command to run.
type Tool struct {
	// Name is the display label shown in the tool list. This is also
	// used as the title of the Terminal.app window when launched.
	Name string
	// Description is a short explanation of what the tool does.
	Description string
	// Command is the shell command executed when the tool is launched.
	// An empty string means the tool is not yet wired up.
	Command string
	// WorkDir is the working directory for the command. If empty, the
	// command runs in whatever directory the TUI was started from.
	WorkDir string
}

// firmwareDir is the absolute path to the PlatformIO firmware project.
const firmwareDir = "/Users/scotthatfield/Documents/Projects/Brine/brine_firmware"

// flutterAppDir is the absolute path to the Brine Flutter application.
const flutterAppDir = "/Users/scotthatfield/Documents/Projects/Brine/brine_app"

// cloudFunctionsDir is the absolute path to the Firebase Cloud Functions project.
const cloudFunctionsDir = "/Users/scotthatfield/Documents/Projects/Brine/brine_cloud_functions"

// defaultTools returns the initial set of development tools available
// in the launcher.
func defaultTools() []Tool {
	return []Tool{
		{
			Name:        "Flash Firmware",
			Description: "Build and flash firmware to the device",
			Command:     "./upload.sh",
			WorkDir:     firmwareDir,
		},
		{
			Name:        "Device Emulator",
			Description: "Build and run the native firmware emulator",
			Command:     "./emulator.sh",
			WorkDir:     firmwareDir,
		},
		{
			Name:        "Serial Monitor",
			Description: "Open serial monitor for device output",
			Command:     "./monitor.sh",
			WorkDir:     firmwareDir,
		},
		{
			Name:        "Flutter App",
			Description: "Launch the Flutter mobile application",
			Command:     "./run.sh",
			WorkDir:     flutterAppDir,
		},
		{
			Name:        "Firebase Emulator",
			Description: "Start the Firebase local emulator suite",
			Command:     "./firebase_emulator_suite.command",
			WorkDir:     cloudFunctionsDir,
		},
	}
}
