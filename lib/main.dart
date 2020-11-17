import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/ManageSavedSuggestions.dart';
import 'package:hello_me/snapping_sheet.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'UserRepo.dart';
import 'LoginPage.dart';
import 'saved.dart';
import 'ManageSavedSuggestions.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserRepository>.value(value: UserRepository.instance()),
          ChangeNotifierProxyProvider<UserRepository, ManageSavedSuggestions>(
              create: (_) => ManageSavedSuggestions(),
              update: (_, UserRepository user, ManageSavedSuggestions mngSavedSug) => mngSavedSug..update(user)
          )
        ],
        child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        home: RandomWords(),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[]; // create a list of type WordPair
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);
      return Scaffold (
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(icon : Icon(Icons.favorite), onPressed: _pushSaved),
            if (user.status != Status.Authenticated)
              IconButton(icon: Icon(Icons.login), onPressed: _login)

            else
              Consumer<UserRepository>(
                  builder: (context, UserRepository user, _){
                    return IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        Provider.of<ManageSavedSuggestions>(context, listen: false).removeSavedSuggestionAtLogOut();
                        user.signOut();
                      }
                    );
                  }
              )
          ],
        ),
        body: _buildSuggestions(),
      );
  }

  void _login(){

    Navigator.of(context).push(
      MaterialPageRoute<void>
        (builder: (BuildContext context){
          return Scaffold(
            appBar: AppBar(
              title: Text('Login')
            ),
            body: LoginPage(),
          );
      })
    );
  }

  void _pushSaved() {

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SavedSuggestions();
        }
        ),
    );
  }


  Widget _buildSuggestions(){
    final UserRepository user = Provider.of<UserRepository>(context);
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (BuildContext _context, int i) {
            if (i.isOdd) {
              return Divider();
            }
            final int index = i ~/ 2;
            if (index >= _suggestions.length) {
              _suggestions.addAll(generateWordPairs().take(10));
            }

            return _buildRow(_suggestions[index]);
          }
        ),
        user.status == Status.Authenticated ?
          MySnappingSheet() :
          Container(),
      ],
    );
  }

  Widget _buildRow(WordPair pair) {

    final ManageSavedSuggestions manageSug = Provider.of<ManageSavedSuggestions>(context);
    final alreadySaved = manageSug.saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved){
            Provider.of<ManageSavedSuggestions>(context, listen: false).removeSug(pair);
          } else {
            Provider.of<ManageSavedSuggestions>(context, listen: false).addSug(pair);
          }
        });
      },
    );
  }
}


