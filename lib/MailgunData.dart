import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mailgun_routes/Secret.dart';

class MailgunData with ChangeNotifier {
  List<MailgunRoute> _routeList;

  MailgunData() {
  }

  List<MailgunRoute> get routeList => _routeList;

  set routeList(List<MailgunRoute> routes) {
    _routeList = routes;
    notifyListeners();
  }

  Future<List<MailgunRoute>> fetchRoutes() async {
    var secret = await SecretLoader().load();
    final response = await http.get('https://api.eu.mailgun.net/v3/routes',
        headers: {HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}'});

    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    var items = responseJson['items'] as List;
    List<MailgunRoute> list =
        items.map((item) => MailgunRoute.fromJson(item)).toList();
    routeList = list;

    return routeList;
  }
}

class MailgunRoute {
  List<String> actions;
  String createdAt;
  String description;
  String expression;
  String id;
  int priority;

  MailgunRoute(
      {this.actions,
      this.createdAt,
      this.description,
      this.expression,
      this.id,
      this.priority});

  factory MailgunRoute.fromJson(Map<String, dynamic> json) {
    return MailgunRoute(
        actions: List<String>.from(json['actions']),
        createdAt: json['created_at'],
        description: json['description'],
        expression: json['expression'],
        id: json['id'],
        priority: json['priority']);
  }
}
