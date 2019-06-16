import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'MailgunData.dart';

void fetchPwnedWebsites(MailgunRoute mailgunRoute) async {
  debugPrint(mailgunRoute.expression);
  Match emailMatch =
      emailPattern.allMatches(mailgunRoute.expression).toList()[0];
  String email =
      mailgunRoute.expression.substring(emailMatch.start, emailMatch.end);
  var urlEncodedEmail = Uri.encodeComponent(email);

  final response = await http.get(
      'https://haveibeenpwned.com/api/v2/breachedaccount/$urlEncodedEmail',
      headers: {HttpHeaders.userAgentHeader: 'Mailgun Routes app'});

  if (response.statusCode == 404) {
    debugPrint("No websites found for email: $email");
    return;
  }

  if (response.statusCode == 400 ||
      response.statusCode == 403 ||
      response.statusCode == 429) {
    debugPrint("Error: ${response.statusCode}");
    debugPrint("Error: ${response.body}");
    return;
//    return Future.error("Error getting HaveIBeenPwned data for email: $email");
  }

  final Map<String, dynamic> responseJson = jsonDecode(response.body);
  var items = responseJson['items'] as List;

  debugPrint("found ${items.length} websites for email: $email");
}

Pattern emailPattern = RegExp(
    r"[a-z0-9!#$%&*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

class PwnedWebsite {
  String title;
}
