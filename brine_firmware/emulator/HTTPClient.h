/**
 * @file HTTPClient.h
 * @brief HTTP client for the native emulator using libcurl.
 *
 * Replaces the ESP32 HTTPClient with a libcurl-backed implementation that
 * provides the same API surface used by FirebaseService and OTAService.
 * This allows the emulator to make real HTTP requests to the Firebase backend.
 */
#ifndef HTTPCLIENT_H_EMULATOR
#define HTTPCLIENT_H_EMULATOR

#include "Arduino.h"
#include "WiFi.h"
#include <curl/curl.h>
#include <map>
#include <string>

/// Callback for libcurl to write response data into a std::string.
static size_t _curlWriteCallback(void *contents, size_t size, size_t nmemb,
                                 void *userp) {
  size_t totalSize = size * nmemb;
  static_cast<std::string *>(userp)->append(static_cast<char *>(contents),
                                            totalSize);
  return totalSize;
}

/// HTTP client matching the ESP32 HTTPClient API surface used by the firmware.
class HTTPClient {
public:
  HTTPClient() : _curl(nullptr), _responseCode(0) {}

  ~HTTPClient() { end(); }

  /// Begin a connection to the given URL (plain HTTP or HTTPS).
  bool begin(const char *url) {
    _url = url;
    return true;
  }

  /// Begin with a WiFiClient reference (ignored, URL is what matters).
  bool begin(WiFiClient &, const char *url) {
    _url = url;
    return true;
  }

  /// Begin with a WiFiClientSecure reference (ignored, libcurl handles TLS).
  bool begin(WiFiClientSecure &, const char *url) {
    _url = url;
    return true;
  }

  /// Add an HTTP header to the next request.
  void addHeader(const char *name, const String &value) {
    _headers[name] = std::string(value.c_str());
  }

  /// Send a POST request with the given payload.
  int POST(const String &payload) {
    _responseBody.clear();
    _curl = curl_easy_init();
    if (!_curl) {
      return -1;
    }

    curl_easy_setopt(_curl, CURLOPT_URL, _url.c_str());
    curl_easy_setopt(_curl, CURLOPT_POST, 1L);
    curl_easy_setopt(_curl, CURLOPT_POSTFIELDS, payload.c_str());
    curl_easy_setopt(_curl, CURLOPT_POSTFIELDSIZE, payload.length());
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, _curlWriteCallback);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, &_responseBody);

    // Build header list
    struct curl_slist *headers = nullptr;
    for (const auto &h : _headers) {
      std::string headerLine = h.first + ": " + h.second;
      headers = curl_slist_append(headers, headerLine.c_str());
    }
    if (headers) {
      curl_easy_setopt(_curl, CURLOPT_HTTPHEADER, headers);
    }

    CURLcode res = curl_easy_perform(_curl);

    if (res != CURLE_OK) {
      printf("[EMULATOR HTTP] curl error: %s\n", curl_easy_strerror(res));
      curl_slist_free_all(headers);
      curl_easy_cleanup(_curl);
      _curl = nullptr;
      _headers.clear();
      return -1;
    }

    long httpCode = 0;
    curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &httpCode);
    _responseCode = static_cast<int>(httpCode);

    curl_slist_free_all(headers);
    curl_easy_cleanup(_curl);
    _curl = nullptr;
    _headers.clear();

    return _responseCode;
  }

  /// Send a GET request.
  int GET() {
    _responseBody.clear();
    _curl = curl_easy_init();
    if (!_curl) {
      return -1;
    }

    curl_easy_setopt(_curl, CURLOPT_URL, _url.c_str());
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, _curlWriteCallback);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, &_responseBody);

    CURLcode res = curl_easy_perform(_curl);

    if (res != CURLE_OK) {
      printf("[EMULATOR HTTP] curl error: %s\n", curl_easy_strerror(res));
      curl_easy_cleanup(_curl);
      _curl = nullptr;
      return -1;
    }

    long httpCode = 0;
    curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &httpCode);
    _responseCode = static_cast<int>(httpCode);

    curl_easy_cleanup(_curl);
    _curl = nullptr;

    return _responseCode;
  }

  /// Get the response body as a String.
  String getString() const { return String(_responseBody.c_str()); }

  /// Get the content length from the last response (-1 if unknown).
  int getSize() const { return static_cast<int>(_responseBody.size()); }

  /// Stub: returns nullptr (stream-based reading not needed for emulator).
  WiFiClient *getStreamPtr() { return nullptr; }

  /// Check if connection is still active (always true for completed requests).
  bool connected() const { return false; }

  /// End the HTTP session and clean up.
  void end() {
    if (_curl) {
      curl_easy_cleanup(_curl);
      _curl = nullptr;
    }
    _headers.clear();
    _responseBody.clear();
  }

private:
  CURL *_curl;
  std::string _url;
  std::map<std::string, std::string> _headers;
  std::string _responseBody;
  int _responseCode;
};

#endif // HTTPCLIENT_H_EMULATOR
