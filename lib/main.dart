import 'package:flutter/material.dart';
import 'package:mailgun_routes/MailgunData.dart';
import 'package:provider/provider.dart';

import 'network.dart';

void main() => runApp(MailgunApp());

class MailgunApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mailgun Routes',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData(
          primarySwatch: Colors.blue, backgroundColor: Colors.grey[850]),
      home: RoutesPage(),
    );
  }
}

class RoutesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  Future<List<MailgunRoute>> _routeList;


  @override
  void initState() {
    super.initState();
    _routeList = fetchRoutes();
  }

  void _addNewRoute() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddRoute()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => MailgunData(),
      child: MyScaffold(
        title: 'Mailgun Routes',
        body: RouteList(routeList: _routeList),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewRoute,
          tooltip: 'Add route',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class RouteList extends StatelessWidget {
  final Future<List<MailgunRoute>> routeList;

  RouteList({this.routeList});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MailgunRoute>>(
      future: routeList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        if (snapshot.hasData) {
          return Flex(direction: Axis.vertical, children: <Widget>[
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.black26,
                    ),
                itemBuilder: (context, position) {
                  return ListTile(
                    title: Text(snapshot.data[position].description),
                    subtitle: Text(snapshot.data[position].expression),
                  );
                },
                itemCount: snapshot.data.length,
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

class AddRoute extends StatelessWidget {
  void _saveRoute() {}

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Add Route',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Route name'),
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Match Recipient'),
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Forward to'),
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
