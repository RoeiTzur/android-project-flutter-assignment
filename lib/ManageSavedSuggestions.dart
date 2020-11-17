import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserRepo.dart';

class ManageSavedSuggestions with ChangeNotifier {

  Set<WordPair> _saved = Set<WordPair>();
  UserRepository _user;
  String _userId;
  CollectionReference _savedSuggestions = FirebaseFirestore.instance.collection(
  'savedSuggestions');

  /** Getters **/
  Set<WordPair> get saved => _saved;
  CollectionReference get savedSuggestions => _savedSuggestions;
  /** functions for Saved Suggestions Set**/

  void removeSug(WordPair pair){
    // remove locally
    _saved.remove(pair);
    // remove cloudly
    if (_user.status == Status.Authenticated)
      removeSugFromCloud(pair);
    notifyListeners();
  }

  Future removeSugFromCloud(WordPair pair) async {
    await _savedSuggestions.doc(_userId).update({'savedSuggestions':
      FieldValue.arrayRemove([
        {'First': pair.first.toString(), 'Second': pair.second.toString()}
      ])
    });
  }

  void addSug(WordPair pair){
    // add locally
    _saved.add(pair);
    // add cloudly
    if (_user.status == Status.Authenticated)
      addSugToCloud(pair);
    notifyListeners();
  }

  Future addSugToCloud(WordPair pair) async {
    await _savedSuggestions.doc(_userId).update({'savedSuggestions':
      FieldValue.arrayUnion([
        {'First': pair.first.toString(), 'Second': pair.second.toString()}
      ])
    });
  }

  bool containsSug(WordPair pair){
    return _saved.contains(pair);
  }

  /** Additional Functions **/

  void removeSavedSuggestionAtLogOut(){
    _saved.clear();
    notifyListeners();
  }
  /** Get info from the UserRepository Class for future use**/
  void update(UserRepository user) async{
    _user = user;
    _userId = user.userId;

    // If the User is loged In, we want to load his saved Suggestions.
    // consider its already exits in the cloud \ need to be created by 'set'.
    if (user.status == Status.Authenticated) {
      var document = await _savedSuggestions.doc(_userId).get();
      if (!document.exists)
        await _savedSuggestions.doc(_userId).set({'savedSuggestions': []});
      // upload local to cloud
      await _savedSuggestions.doc(_userId).update(
          { 'savedSuggestions': FieldValue.arrayUnion(List<dynamic>.from(
              _saved.map((pair) => {'First': pair.first, 'Second': pair.second})
             )
            )
          }
      );
      // load the saved suggestions from cloud:
      _saved = await pullSavedSuggestions();
    }
    notifyListeners();
  }

  Future<Set<WordPair>> pullSavedSuggestions() {
    return _savedSuggestions
        .doc(_userId)
        .get()
        .then((document) => document.data())
        .then((savedSug) => savedSug == null
        ? Set<WordPair>()
        : Set<WordPair>.from(savedSug['savedSuggestions'].map((element)
          => WordPair(element['First'], element['Second']))));
  }

}