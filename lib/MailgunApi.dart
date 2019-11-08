import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'MailgunData.dart';
import 'Secret.dart';

class MailgunApi {
  Future<List<MailgunRoute>> fetchRoutes() async {
    var secret = await SecretLoader().load();
    final response = await http.get('https://api.eu.mailgun.net/v3/routes?limit=1000', headers: {HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}'});

    debugPrint("Fetching routes");
    if (response.statusCode == 401) {
      debugPrint("Error fetching route data");
      return Future.error("Error fetching route data");
    }

    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    var items = responseJson['items'] as List;
    debugPrint("Got ${items.length} items");

    List<MailgunRoute> list = items.map((item) {
      var mailgunRoute = MailgunRoute.fromJson(item);
//        fetchPwnedWebsites(mailgunRoute);
      return mailgunRoute;
    }).toList();

    return list;
  }

  Future<bool> saveRoute(RoutePostBody routeData) async {
    var secret = await SecretLoader().load();
    var request = http.MultipartRequest("POST", Uri.parse('https://api.eu.mailgun.net/v3/routes'));
    request.headers.addAll({HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}', HttpHeaders.contentTypeHeader: 'multipart/form-data'});
    request.fields['priority'] = ["0"];
    request.fields['description'] = [routeData.description];
    request.fields['expression'] = [routeData.expression];
    request.fields['action'] = routeData.action;

//  request.fields.addAll(routeData.toMap());

    debugPrint(request.fields.toString());

    debugPrint("Saving route: ${routeData.description}");

    var response = await request.send();

    var body = await response.stream.bytesToString();

    debugPrint("Body: $body");

    var createRouteResponse = CreateRouteResponse.fromJson(jsonDecode(body));

    return createRouteResponse.message.contains("Route has been created");
  }

  deleteRoute(String id) async {
    var secret = await SecretLoader().load();
    final response = await http.delete("https://api.eu.mailgun.net/v3/routes/$id", headers: {HttpHeaders.authorizationHeader: 'Basic ${secret.apiKey}'});

    debugPrint("Deleting route $id");

    if (response.statusCode == 401 || response.statusCode == 404) {
      debugPrint("Error deleting route");
    }

    if (response.statusCode == 200) {
      debugPrint("Route deleted");
    }
  }
}

class CreateRouteResponse {
  String message;
  MailgunRoute route;

  CreateRouteResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    route = json['route'] != null ? MailgunRoute.fromJson(json['route']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.route != null) {
      data['route'] = this.route.toJson();
    }
    return data;
  }
}

class RoutePostBody {
  List<String> _action;
  String _description;
  String _expression;
  int _priority = 0;

  String get description => _description;

  set name(String name) {
    _description = name;
  }

  List<String> get action => _action;

  set destinationEmail(String destinationEmail) {
    _action = ["forward(\"$destinationEmail\")", "stop()"];
  }

  String get expression => _expression;

  set sourceEmail(String sourceEmail) {
    _expression = "match_recipient('$sourceEmail')";
  }

  RoutePostBody();

  RoutePostBody.fromJson(Map<String, dynamic> json) {
    _action = json['actions'].cast<String>();
    _description = json['description'];
    _expression = json['expression'];
    _priority = json['priority'];
  }

  Map<String, String> toJson() => {'priority': _priority.toString(), 'description': _description, 'action': _action.toString(), 'expression': _expression};
}
