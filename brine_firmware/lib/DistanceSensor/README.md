# DistanceSensor Library

A unified interface for VL53L0X and VL53L1X distance sensors that allows switching between sensor types at compile time.

## Features

- **Unified API**: Same interface for both VL53L0X and VL53L1X sensors
- **Compile-time Configuration**: Choose sensor type with build flags
- **Compatible Interface**: Drop-in replacement for existing VL53L1XSensor code
- **Automatic Library Selection**: Includes appropriate sensor library based on configuration

## Supported Sensors

- **VL53L1X** (default): Uses SparkFun VL53L1X library, range up to 4000mm
- **VL53L0X**: Uses Adafruit VL53L0X library, range up to 2000mm

## Usage

### Basic Usage

```cpp
#include <DistanceSensor.h>

DistanceSensor sensor;

void setup() {
  Wire.begin();
  
  if (sensor.begin(Wire)) {
    Serial.println("Sensor initialized successfully");
    Serial.print("Using sensor type: ");
    Serial.println(sensor.getSensorType());
  }
}

void loop() {
  sensor.startMeasurement();
  int distance = sensor.getDistance();
  int status = sensor.getRangeStatus();
  
  if (status == 0) {
    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.println(" mm");
  } else {
    Serial.print("Measurement error, status: ");
    Serial.println(status);
  }
  
  delay(1000);
}
```

### Compile-time Configuration

#### Using VL53L1X (default)
```bash
pio run
```

#### Using VL53L0X
```bash
pio run -e your_environment -D VL53L0X_SENSOR
```

Or add to your `platformio.ini`:
```ini
[env:your_environment]
build_flags = -DVL53L0X_SENSOR
```

## API Reference

### Constructor
- `DistanceSensor()` - Creates a new distance sensor instance

### Methods
- `bool begin(TwoWire &i2cBus)` - Initialize the sensor
- `void startMeasurement()` - Start a distance measurement
- `int getDistance()` - Get distance in millimeters
- `int getRangeStatus()` - Get measurement status (0=success, 1=signal fail, 2=sigma fail, 7=wrapped target fail)
- `void stopMeasurement()` - Stop ongoing measurements
- `String getSensorType()` - Returns "VL53L0X" or "VL53L1X"

## Dependencies

### For VL53L1X (default)
- SparkFun VL53L1X 4m Laser Distance Sensor library

### For VL53L0X
- Adafruit VL53L0X library

## Testing

Run tests for the current configuration:
```bash
pio test --filter test_DistanceSensor
```

Test with VL53L0X:
```bash
pio test --filter test_DistanceSensor -D VL53L0X_SENSOR
```

## Hardware Connections

Both sensors use I2C communication:
- **VCC**: 3.3V
- **GND**: Ground
- **SDA**: I2C Data
- **SCL**: I2C Clock

Default I2C address: 0x29 (both sensors)