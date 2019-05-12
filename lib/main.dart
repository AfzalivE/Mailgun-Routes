import 'package:flutter/material.dart';
import 'package:mailgun_routes/MailgunData.dart';
import 'package:provider/provider.dart';

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
  void _addNewRoute() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddRoute()));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('print me');
    return ChangeNotifierProvider(
      builder: (context) => MailgunData(),
      child: MyScaffold(
        title: 'Mailgun Routes',
        body: RouteList(),
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
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<MailgunData>(context);
    return FutureBuilder<List<MailgunRoute>>(
      future: data.fetchRoutes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        if (snapshot.hasData) {
          return Flex(direction: Axis.vertical, children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Card(
                        child: Text(data.routeList[position].description));
                  },
                  itemCount: data.routeList.length),
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
