import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'ManageSavedSuggestions.dart';
import 'package:provider/provider.dart';


class SavedSuggestions extends StatefulWidget {
  @override
  _SavedSuggestionsState createState() => _SavedSuggestionsState();
}

class _SavedSuggestionsState extends State<SavedSuggestions> {

  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final Set<WordPair> _saved = Provider.of<ManageSavedSuggestions>(context).saved;
    final tiles = _saved.map(
          (WordPair pair) {
            return ListTile(
              title: Text(
                pair.asPascalCase,
                style: _biggerFont,
              ),
              trailing: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon (
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Provider.of<ManageSavedSuggestions>(context, listen: false).removeSug(pair);
                    }
                  );
                },
              ),
            );
         },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }
}
