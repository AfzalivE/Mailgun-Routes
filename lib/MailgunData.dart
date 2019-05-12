import 'package:flutter/foundation.dart';

class MailgunData with ChangeNotifier {
  List<MailgunRoute> _routeList;

  List<MailgunRoute> get routeList => _routeList;

  set routeList(List<MailgunRoute> routes) {
    _routeList = routes;
    notifyListeners();
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
