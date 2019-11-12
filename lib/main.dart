import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'MailgunApi.dart';
import 'MailgunData.dart';

void main() {
  _setTargetPlatformForDesktop();
  runApp(MailgunApp());
}

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MailgunApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      builder: (context) => MailgunApi(),
      child: MaterialApp(
        title: 'Mailgun Routes',
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData(primarySwatch: Colors.blue, backgroundColor: Colors.grey[850]),
        home: RoutesPage(),
      ),
    );
  }
}

class RoutesPage extends StatelessWidget {

  void _addNewRoute(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddRoutePage()));
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        title: 'Mailgun Routes',
        body: RouteList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addNewRoute(context),
          tooltip: 'Add route',
          child: Icon(Icons.add),
        )
    );
  }
}

class RouteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoutesListState();
}

class _RoutesListState extends State<RouteList> {
  Future<List<MailgunRoute>> _routeList;

  Future<void> _refreshList() async {
    var mailgunApi = Provider.of<MailgunApi>(context);
    final newRouteList = mailgunApi.fetchRoutes();
    if (newRouteList != _routeList) {
      setState(() {
        _routeList = newRouteList;
      });
    }
  }

  Future<void> _deleteRoute(int position) async {
    var mailgunApi = Provider.of<MailgunApi>(context);
    _routeList.then((list) {
      debugPrint("Going to delete item at $position, which is ${list[position].description}");
      var id = list[position].id;
      list.removeAt(position); // remove from list first
      mailgunApi.deleteRoute(id);
      _refreshList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MailgunRoute>>(
      future: _routeList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error));
        }

        if (snapshot.hasData) {
          return Flex(direction: Axis.vertical, children: <Widget>[
            Expanded(
              child: LiquidPullToRefresh(
                showChildOpacityTransition: false,
                onRefresh: _refreshList,
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.black26,
                  ),
                  itemBuilder: (context, position) {
                    return Slidable(
                      key: ValueKey(snapshot.data[position].id),
                      actionPane: SlidableScrollActionPane(),
                      child: ListTile(
                        title: Text(snapshot.data[position].description),
                        subtitle: Text(snapshot.data[position].expression),
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteRoute(position),
                        ),
                      ],
                    );
                  },
                  itemCount: snapshot.data.length,
                ),
              ),
            ),
          ]);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


class AddRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Add Route',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddRouteForm(),
      ),
    );
  }
}

class AddRouteForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddRouteFormState();
  }
}

class AddRouteFormState extends State<AddRouteForm> {
  final _formKey = GlobalKey<FormState>();
  final _routeData = RoutePostBody();
  var _nameController = TextEditingController();
  var _emailController = TextEditingController();
  var _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(onChange);
  }

  void _saveRoute() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    var savingRoute = Scaffold.of(context).showSnackBar(SnackBar(content: Text('Saving route')));

    var mailgunApi = Provider.of<MailgunApi>(context);
    var saveRouteResponse = mailgunApi.saveRoute(_routeData);
    savingRoute.close();

    saveRouteResponse.then((routeSaved) => {Scaffold.of(context).showSnackBar(SnackBar(content: Text('Route saved')))});
  }

  void onChange() {
    var name = _nameController.text.toLowerCase().replaceAll(" ", "");
    _emailController.text = "$name@mydomain.com";
    _destinationController.text = "myemail+$name@gmail.com";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value.isEmpty) {
                return "Please enter a name for this route";
              } else {
                _routeData.name = value;
              }
              return null;
            },
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Route name'),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value.isEmpty) {
                return "Please enter an email for this route";
              } else {
                _routeData.sourceEmail = value;
              }
              return null;
            },
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Match Recipient'),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _destinationController,
            validator: (value) {
              if (value.isEmpty) {
                return "Please enter the destination email for this route";
              } else {
                _routeData.destinationEmail = value;
              }
              return null;
            },
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Forward to'),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                elevation: 4,
                onPressed: _saveRoute,
                child: Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class MyScaffold extends StatefulWidget {
  MyScaffold({this.title, this.body, this.floatingActionButton}) : super();

  final String title;
  final Widget body;
  final Widget floatingActionButton;

  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: widget.body,
        floatingActionButton: widget.floatingActionButton);
  }
}
