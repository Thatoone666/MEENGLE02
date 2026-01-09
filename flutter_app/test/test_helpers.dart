import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';

class FakeApiClient implements ApiClient {
  final List<RecordedRequest> requests = [];

  // configure responses by path
  final Map<String, http.Response> responses = {};
  final Map<String, http.StreamedResponse> streamedResponses = {};

  void when(String url, http.Response response) {
    responses[url] = response;
  }

  void whenGet(String path, http.Response response) =>
      responses[path] = response;
  void whenPost(String path, http.Response response) =>
      responses[path] = response;
  void whenPut(String path, http.Response response) =>
      responses[path] = response;
  void whenStreamed(String path, http.StreamedResponse response) =>
      streamedResponses[path] = response;

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    requests.add(RecordedRequest('GET', uri, headers, null));
    final key = uri.toString();
    if (responses.containsKey(key)) return responses[key]!;
    return http.Response('{}', 200);
  }

  @override
  Future<http.Response> post(Uri uri,
      {Map<String, String>? headers, Object? body}) async {
    requests.add(RecordedRequest('POST', uri, headers, body));
    final key = uri.toString();
    if (responses.containsKey(key)) return responses[key]!;
    return http.Response('{}', 200);
  }

  @override
  Future<http.Response> put(Uri uri,
      {Map<String, String>? headers, Object? body}) async {
    requests.add(RecordedRequest('PUT', uri, headers, body));
    final key = uri.toString();
    if (responses.containsKey(key)) return responses[key]!;
    return http.Response('{}', 200);
  }

  @override
  Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) async {
    requests.add(RecordedRequest('DELETE', uri, headers, null));
    final key = uri.toString();
    if (responses.containsKey(key)) return responses[key]!;
    return http.Response('{}', 200);
  }

  @override
  Future<http.StreamedResponse> sendMultipart(http.MultipartRequest req) async {
    requests.add(RecordedRequest('MULTIPART', req.url, req.headers, null));
    final key = req.url.toString();
    if (streamedResponses.containsKey(key)) return streamedResponses[key]!;
    // default: empty 200
    final body = utf8.encode('{}');
    final stream = Stream<List<int>>.fromIterable([body]);
    return http.StreamedResponse(stream, 200);
  }

  RecordedRequest? lastRequest() => requests.isNotEmpty ? requests.last : null;
}

class RecordedRequest {
  final String method;
  final Uri uri;
  final Map<String, String>? headers;
  final Object? body;
  RecordedRequest(this.method, this.uri, this.headers, this.body);
}
