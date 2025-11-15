import 'dart:io';
import 'package:fake_http_client/fake_http_client.dart';

/// A mock server for intercepting and providing custom responses to HTTP requests in Dart/Flutter tests.
///
/// In Dart/Flutter test environments, making actual HTTP requests result in `400 Bad Request` responses due to
/// constraints imposed by the test environment. The [MockHttpServer] class addresses this limitation by extending
/// [HttpOverrides], allowing developers to intercept HTTP requests and provide predefined responses using a
/// [FakeHttpResponse].
///
/// The primary purpose of [MockHttpServer] is to facilitate testing of code that relies on HTTP requests by providing
/// controlled, deterministic responses. This is crucial for testing scenarios where the behavior of the code under
/// different HTTP response conditions needs to be validated, such as handling success, failure, or specific HTTP status
/// codes.
///
/// The [responseBuilder] function, provided at the time of instantiation, is used to generate a [FakeHttpResponse].
/// This response can include an HTTP status code, headers, and body, allowing tests to simulate various server
/// responses and ensure that the client-side code behaves as expected.
///
/// Example usage:
/// ```dart
/// // Create a MockHttpServer with a responseBuilder that returns a 200 OK response.
/// final mockServer = MockHttpServer(() {
/// return FakeHttpResponse(
/// statusCode: 200,
/// body: 'Success',
/// );
/// });
///
/// // Override the global HttpClient with the mock server's client.
/// HttpOverrides.global = mockServer;
///
/// // Now, any HTTP request made will receive the mocked response.
/// ```
class MockHttpServer extends HttpOverrides {
  /// Creates an instance of [MockHttpServer] with the given [responseBuilder].
  ///
  /// The [responseBuilder] function is called whenever an HTTP request is made, providing a [FakeHttpResponse] that
  /// simulates a real server response. This enables the testing of client-side HTTP handling logic without making
  /// actual network calls.
  MockHttpServer(this.responseBuilder);

  /// A function that returns a [FakeHttpResponse] representing a mocked response from a REST API.
  final FakeHttpResponse Function() responseBuilder;

  @override
  HttpClient createHttpClient(_) {
    return FakeHttpClient((request, client) {
      // The mocked response is determined by the responseBuilder function.
      return responseBuilder();
    });
  }
}
