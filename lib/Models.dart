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
