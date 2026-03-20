/**
 * @file Arduino.h
 * @brief Minimal Arduino API stubs for the native emulator build.
 *
 * Provides just enough of the Arduino API surface to compile the Brine firmware's
 * service layer (FirebaseService, NVSService, DebugService, etc.) on a desktop
 * machine. Hardware-specific functionality (GPIO, I2C, interrupts) is intentionally
 * omitted since the emulator replaces those code paths entirely.
 */
#ifndef ARDUINO_H_EMULATOR
#define ARDUINO_H_EMULATOR

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <chrono>
#include <string>
#include <thread>

// --- Basic Arduino type aliases ---
typedef uint8_t byte;

// --- Pin mode constants (no-ops in emulator) ---
#define INPUT 0
#define OUTPUT 1
#define INPUT_PULLUP 2
#define LOW 0
#define HIGH 1
#define FALLING 2
#define RISING 3
#define CHANGE 4
#define A0 0
#define A1 1
#define HEX 16
#define DEC 10

// --- Arduino String class ---
class String {
public:
  String() : _buf() {}
  String(const char *s) : _buf(s ? s : "") {}
  String(const std::string &s) : _buf(s) {}
  String(int val) : _buf(std::to_string(val)) {}
  String(unsigned int val) : _buf(std::to_string(val)) {}
  String(long val) : _buf(std::to_string(val)) {}
  String(unsigned long val) : _buf(std::to_string(val)) {}
  String(float val, int decimalPlaces = 2) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%.*f", decimalPlaces, val);
    _buf = buf;
  }
  String(double val, int decimalPlaces = 2) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%.*f", decimalPlaces, val);
    _buf = buf;
  }
  /// Constructor for integer with base (e.g. HEX).
  String(unsigned char val, int base) {
    char buf[16];
    if (base == 16) snprintf(buf, sizeof(buf), "%x", val);
    else snprintf(buf, sizeof(buf), "%d", val);
    _buf = buf;
  }

  const char *c_str() const { return _buf.c_str(); }
  unsigned int length() const { return _buf.length(); }
  size_t size() const { return _buf.size(); }
  bool isEmpty() const { return _buf.empty(); }

  /// Character access for ArduinoJson Reader compatibility.
  char operator[](unsigned int index) const {
    if (index >= _buf.size()) return '\0';
    return _buf[index];
  }

  /// Stream-like read() for ArduinoJson deserialization support.
  int read() {
    if (_readPos >= _buf.size()) return -1;
    return static_cast<unsigned char>(_buf[_readPos++]);
  }

  /// Returns how many bytes are left to read.
  size_t available() const {
    return _readPos < _buf.size() ? _buf.size() - _readPos : 0;
  }

  /// Write a single byte (for ArduinoJson serialization support).
  size_t write(uint8_t c) {
    _buf += static_cast<char>(c);
    return 1;
  }

  /// Write a buffer of bytes.
  size_t write(const uint8_t *buf, size_t len) {
    _buf.append(reinterpret_cast<const char *>(buf), len);
    return len;
  }

  String substring(unsigned int from, unsigned int to) const {
    if (from >= _buf.size()) return String();
    return String(_buf.substr(from, to - from));
  }

  void replace(const String &find, const String &rep) {
    size_t pos = 0;
    while ((pos = _buf.find(find._buf, pos)) != std::string::npos) {
      _buf.replace(pos, find._buf.length(), rep._buf);
      pos += rep._buf.length();
    }
  }

  int indexOf(const char *s) const {
    size_t pos = _buf.find(s);
    return pos == std::string::npos ? -1 : static_cast<int>(pos);
  }

  String operator+(const String &rhs) const { return String(_buf + rhs._buf); }
  String operator+(const char *rhs) const { return String(_buf + rhs); }
  String &operator+=(const String &rhs) { _buf += rhs._buf; return *this; }
  String &operator+=(const char *rhs) { _buf += rhs; return *this; }
  bool operator==(const String &rhs) const { return _buf == rhs._buf; }
  bool operator!=(const String &rhs) const { return _buf != rhs._buf; }

  friend String operator+(const char *lhs, const String &rhs) {
    return String(std::string(lhs) + rhs._buf);
  }

private:
  std::string _buf;
  size_t _readPos = 0;
};

// --- Timing functions ---
inline unsigned long millis() {
  static auto start = std::chrono::steady_clock::now();
  auto now = std::chrono::steady_clock::now();
  return std::chrono::duration_cast<std::chrono::milliseconds>(now - start).count();
}

inline void delay(unsigned long ms) {
  std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

// --- Serial stub ---
class SerialClass {
public:
  void begin(unsigned long) {}
  void print(const String &s) { printf("%s", s.c_str()); }
  void print(const char *s) { printf("%s", s); }
  void print(int v) { printf("%d", v); }
  void println(const String &s) { printf("%s\n", s.c_str()); }
  void println(const char *s) { printf("%s\n", s); }
  void println(int v) { printf("%d\n", v); }
  void println() { printf("\n"); }
  explicit operator bool() const { return true; }
};

static SerialClass Serial;

// --- GPIO stubs (no-ops) ---
inline void pinMode(int, int) {}
inline int digitalRead(int) { return HIGH; }
inline void digitalWrite(int, int) {}
inline void attachInterrupt(int, void(*)(), int) {}
inline void detachInterrupt(int) {}
inline int digitalPinToInterrupt(int pin) { return pin; }

// --- Wire / I2C stub ---
class TwoWire {
public:
  void begin(int, int) {}
  void begin() {}
};

static TwoWire Wire;

// --- ESP32-specific stubs ---
typedef int gpio_num_t;
#define GPIO_NUM_MAX 40
#define GPIO_NUM_32 32

typedef int esp_err_t;
#define ESP_OK 0

typedef int esp_sleep_wakeup_cause_t;
#define ESP_SLEEP_WAKEUP_UNDEFINED 0
#define ESP_SLEEP_WAKEUP_EXT0 2
#define ESP_SLEEP_WAKEUP_EXT1 3
#define ESP_SLEEP_WAKEUP_TIMER 4

inline esp_sleep_wakeup_cause_t esp_sleep_get_wakeup_cause() {
  return ESP_SLEEP_WAKEUP_UNDEFINED;
}
inline esp_err_t esp_sleep_enable_timer_wakeup(uint64_t) { return ESP_OK; }
inline esp_err_t esp_sleep_enable_ext1_wakeup(uint64_t, int) { return ESP_OK; }
inline void esp_deep_sleep_start() {}
inline void gpio_pullup_en(int) {}
inline void gpio_pulldown_dis(int) {}
inline esp_err_t rtc_gpio_pullup_en(int) { return ESP_OK; }
inline void rtc_gpio_pulldown_dis(int) {}
inline void rtc_gpio_isolate(int) {}

#define ESP_EXT1_WAKEUP_ANY_LOW 0
#define ESP_EXT1_WAKEUP_ALL_LOW 1
#define ESP_EXT1_WAKEUP_ANY_HIGH 2

// --- ESP restart stub ---
class ESPClass {
public:
  void restart() {
    printf("[EMULATOR] ESP.restart() called. Exiting.\n");
    exit(0);
  }
};

static ESPClass ESP;

// --- IRAM_ATTR is a no-op on native ---
#define IRAM_ATTR

#endif // ARDUINO_H_EMULATOR
