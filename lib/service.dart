import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

const String baseUrl = "http://192.168.0.15:8080";

Future<http.Response> getStatus() {
  try {
    return http.get(Uri.parse("$baseUrl/status"));
  } on SocketException {
    throw Exception("Homeserver api unreachable");
  }
}

Future<http.Response> getTemp() {
  try {
    return http.get(Uri.parse("$baseUrl/temp"));
  } on SocketException {
    throw Exception("Homeserver api unreachable");
  }
}

Future<http.Response> turnOn() {
  try {
    return http.put(
        Uri.parse("https://jsonblob.com/api/jsonBlob/$jsonBlobPath"),
        headers: {"Content-Type": "application/json"},
        body: DateTime.now().toString());
  } on SocketException {
    throw Exception("Homeserver api unreachable");
  }
}

Future<http.Response> turnOff() {
  try {
    return http.get(Uri.parse("$baseUrl/suspend"));
  } on SocketException {
    throw Exception("Homeserver api unreachable");
  }
}
