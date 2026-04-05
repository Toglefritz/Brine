# Brine

PCB design and hardware reference for the Brine Monitor, an IoT device that monitors the amount of
salt remaining in a water softener.

## Hello :wave:

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe
bet to say that everybody who has a water softener in their home forgets to refill the salt from
time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener
and delivers alerts when the level is low. With this tool, you can keep your water softener filled
with salt and working properly, which, in turn, will keep your appliances free of mineral deposits,
your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

## Hardware Overview

The Brine device is a battery-powered sensor board built around a Seeed Studio XIAO ESP32-S3
module. It measures the distance from the top of a water softener to the salt surface using a
VL53L1X time-of-flight distance sensor, then reports that measurement to the cloud over WiFi.

The board includes:

- XIAO ESP32-S3 microcontroller module (WiFi, BLE, and GPIO)
- VL53L1X time-of-flight distance sensor connected over I2C
- Battery power input with a voltage divider for battery level monitoring
- A physical button for entering setup mode and waking from deep sleep
- An RGB LED for status indication during provisioning and operation

The PCB is a two-layer board designed to fit inside a custom enclosure. Enclosure models are
maintained separately in the [`brine_cad`](../brine_cad/) directory.

## KiCAD Project

The active design lives in the `Brine Mainboard/` directory and is a KiCAD 9 project.

### Hierarchical Schematic Structure

The schematic is organized as a set of hierarchical sheets. The root sheet (`Brine.kicad_sch`)
acts as a block diagram of the hardware, showing each functional block and the signals that
connect them. Each block is defined in its own schematic sheet with the full circuit detail for
that subsystem.

| Sheet | File | Description |
|---|---|---|
| Root | `Brine.kicad_sch` | Top-level block diagram showing all subsystems and their interconnections. |
| XIAO ESP32-S3 | `xiao_esp32-s3.kicad_sch` | Microcontroller module pinout and connections to all peripheral blocks. |
| Battery | `brine_battery.kicad_sch` | Battery input and power delivery. |
| Button | `brine_button.kicad_sch` | Physical pushbutton circuit for user interaction and wake-from-sleep. |
| RGB LED | `brine_rgb_led.kicad_sch` | Status LED driven by the microcontroller. |
| Battery Monitor | `brine_battery_monitor.kicad_sch` | Voltage divider circuit for reading battery level on an analog input. |
| Distance Sensor | `brine_distance_sensor.kicad_sch` | VL53L1X time-of-flight sensor with I2C and shutdown control lines. |

The root sheet is the best starting point for understanding how the subsystems relate to each
other. Open it in KiCAD's schematic editor to see the block-level signal flow, then navigate into
individual sheets for component-level detail.

### PCB Layout

The PCB (`Brine.kicad_pcb`) is a two-layer board. A 3D STEP model of the board (`Brine.step`) is
included for use in enclosure design and fit verification.

Production outputs, including Gerbers, BOM, and pick-and-place position files, are generated into
the `production/` subdirectory.

## Directory Structure

| Directory | Description |
|---|---|
| `Brine Mainboard/` | Active KiCAD project containing schematics, PCB layout, production outputs, and the board STEP model. |
| `Libraries/` | Custom KiCAD symbol and footprint libraries for components not available in the default KiCAD libraries (e.g., VL53L1X). |
| `Gerbers/` | Legacy Gerber output directory. Current production files are generated into `Brine Mainboard/production/`. |
| `Archive/` | Previous board revisions and design iterations, including earlier EAGLE-based designs. Kept for reference. |
