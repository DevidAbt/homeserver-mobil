import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

const String baseUrl = "http://192.168.0.15:8080";

const timeout = Duration(seconds: 5);

Future<http.Response> getStatus() {
  try {
    return http.get(Uri.parse("$baseUrl/status")).timeout(timeout);
  } on SocketException {
    throw Exception("Homeserver api unreachable");
  }
}

Future<http.Response> getTemp() {
  try {
    return http.get(Uri.parse("$baseUrl/temp")).timeout(timeout);
    ;
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

Future<String?> getCsrfToken() async {
  try {
    http.Response response = await http.get(Uri.parse("https://rentry.co"));
    return response.headers["set-cookie"];
  } on SocketException {
    throw Exception("Rentry api unreachable");
  }
}

Future<http.Response> turnOn2() async {
  try {
    String? csfrToken = await getCsrfToken();
    if (csfrToken == null) {
      log("cannot get csfr token");
      throw Exception("Cannot get csfr token");
    }
    http.Response response = await http
        .post(Uri.parse("https://rentry.co/api/edit/$turnOnRentryPath"), body: {
      "csrfmiddlewaretoken": csfrToken.split("csrftoken=")[1].split(";")[0],
      "edit_code": rentryEditCode,
      "text": DateTime.now().toString()
    }, headers: {
      "Referer": "https://rentry.co",
      "Cookie": csfrToken
    });
    return response;
  } on SocketException {
    throw Exception("Rentry api unreachable");
  }
}
