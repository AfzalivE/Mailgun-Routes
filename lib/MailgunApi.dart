import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'Models.dart';
import 'Secret.dart';

class MailgunApi {
  List<MailgunRoute> list = [];

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

    list = items.map((item) {
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

