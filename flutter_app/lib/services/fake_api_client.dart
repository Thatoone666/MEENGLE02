import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';

/// Minimal fake API client to use in unit tests. Callers can set
/// ApiService.client = FakeApiClient(); and then populate responses.
class FakeApiClient implements ApiClient {
  final Map<String, http.Response> _responses = {};

  void when(String url, http.Response response) {
    _responses[url] = response;
  }

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    return _responses[uri.toString()] ?? http.Response('{}', 404);
  }

  @override
  Future<http.Response> post(Uri uri,
      {Map<String, String>? headers, Object? body}) async {
    return _responses[uri.toString()] ?? http.Response('{}', 404);
  }

  @override
  Future<http.Response> put(Uri uri,
      {Map<String, String>? headers, Object? body}) async {
    return _responses[uri.toString()] ?? http.Response('{}', 404);
  }

  @override
  Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) async {
    return _responses[uri.toString()] ?? http.Response('{}', 404);
  }

  @override
  Future<http.StreamedResponse> sendMultipart(http.MultipartRequest req) async {
    final r = _responses[req.url.toString()];
    if (r == null) {
      return http.StreamedResponse(Stream.value(utf8.encode('{}')), 404);
    }
    return http.StreamedResponse(
        Stream.value(utf8.encode(r.body)), r.statusCode);
  }
}
