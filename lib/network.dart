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
  if (response.statusCode == 401) {
    return Future.error("Error fetching route data");
  }

  final Map<String, dynamic> responseJson = jsonDecode(response.body);
  var items = responseJson['items'] as List;
  List<MailgunRoute> list =
      items.map((item) => MailgunRoute.fromJson(item)).toList();

  data.routeList = list;
  return list;
}

void saveRoute(RouteData routeData) async {
  var secret = await SecretLoader().load();
  final response = await http.post('https://api.eu.mailgun.net/v3/routes',
      headers: {HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}'},
      body: jsonEncode(routeData));

  debugPrint("Saving route: ${routeData.description}");

  debugPrint("Body: ${response.body}");
}

class RouteData {
  int _priority = 0;
  String _description;

  String get description => _description;

  set name(String name) {
    _description = name;
  }
  List<String> _action;

  List<String> get action => _action;

  set destinationEmail(String destinationEmail) {
    _action = ["forward(\"$destinationEmail\")", "stop()"];
  }
  String _expression;

  String get expression => _expression;

  set sourceEmail(String sourceEmail) {
    _expression = "match_recipient('$sourceEmail')";
  }

  Map<String, dynamic> toJson() =>
      {
        'priority' : _priority,
        'description': _description,
        'action': _action,
        'expression': _expression
      };

//  RouteData(String name, String sourceEmail, String destinationEmail) {
//    this.priority = 0;
//    this.description = name;
//    this.expression = "match_recipient('$sourceEmail')";
//    this.action = ["forward(\"$destinationEmail\")", "stop()"];
//  }
}
