import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'MailgunData.dart';
import 'Secret.dart';

Future<List<MailgunRoute>> fetchRoutes(MailgunData data) async {
  var secret = await SecretLoader().load();
  final response = await http.get('https://api.eu.mailgun.net/v3/routes',
      headers: {HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}'});

  debugPrint("Fetching routes");
  final Map<String, dynamic> responseJson = jsonDecode(response.body);
  var items = responseJson['items'] as List;
  List<MailgunRoute> list =
      items.map((item) => MailgunRoute.fromJson(item)).toList();

  data.routeList = list;
  return list;
}
