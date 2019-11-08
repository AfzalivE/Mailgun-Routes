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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['actions'] = this.actions;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['expression'] = this.expression;
    data['id'] = this.id;
    data['priority'] = this.priority;
    return data;
  }
}
