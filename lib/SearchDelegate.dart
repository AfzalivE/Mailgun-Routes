import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'MailgunApi.dart';
import 'Models.dart';

class SearchAppBarDelegate extends SearchDelegate {
  //list holds the full word list
  List<MailgunRoute> _routes;

  SearchAppBarDelegate(List<MailgunRoute> Function() getList)
      : _routes = getList(),
        super();

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isNotEmpty
          ? IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          : Container(),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        //Take control back to previous page
        this.close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // not used
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                this.close(context, this.query);
              },
              child: Text(
                this.query,
                style: Theme.of(context)
                    .textTheme
                    .display2
                    .copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final String queryLow = query.toLowerCase();

    Iterable<MailgunRoute> suggestions = this.query.isEmpty
        ? _routes
        : _routes.where((route) {
            return route.description.toLowerCase().contains(queryLow) ||
                route.expression.toLowerCase().contains(queryLow);
          });

    return _RouteSuggestionList(
      query: queryLow,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        this.query = suggestion;
        showResults(context);
      },
      onDeleted: (String id) {
        _deleteRoute(context, id);
      },
    );
  }

  _deleteRoute(BuildContext context, String id) {
    var mailgunApi = Provider.of<MailgunApi>(context);
    mailgunApi.deleteRoute(id);
    _routes.removeWhere((route) => route.id == id);
    query = query;
  }
}

class _RouteSuggestionList extends StatelessWidget {
  const _RouteSuggestionList(
      {this.suggestions, this.query, this.onSelected, this.onDeleted});

  final List<MailgunRoute> suggestions;
  final String query;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onDeleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.subhead;

    return ListView.separated(
      separatorBuilder: (context, position) =>
          Divider(color: Colors.black26, height: 0.0),
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final MailgunRoute suggestedRoute = suggestions[i];
        final String suggestionLow = suggestedRoute.description.toLowerCase();
        final String suggestion = suggestedRoute.description;

        final bool suggestionContainsQuery =
            query.isNotEmpty && suggestionLow.contains(query);

        final int matchStartIndex =
            suggestionContainsQuery ? suggestionLow.indexOf(query) : 0;
        final int matchEndIndex =
            suggestionContainsQuery ? matchStartIndex + query.length : 0;

        return Slidable(
          key: ValueKey(suggestedRoute.id),
          actionPane: SlidableScrollActionPane(),
          secondaryActions: [
            IconSlideAction(
              caption: "Delete",
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => onDeleted(suggestedRoute.id),
            )
          ],
          child: ListTile(
            subtitle: Text(suggestedRoute.expression),
            title: RichText(
              text: TextSpan(
                text: suggestion.substring(0, matchStartIndex),
                style: textTheme,
                children: [
                  TextSpan(
                      text:
                          suggestion.substring(matchStartIndex, matchEndIndex),
                      style: textTheme.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: suggestion.substring(
                              matchEndIndex, suggestion.length),
                          style: textTheme,
                        )
                      ])
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
