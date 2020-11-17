import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Unauthenticated;
  String _userId;
  String _mail;
  String _picture;
  CollectionReference _savedSuggestions = FirebaseFirestore.instance.collection(
      'savedSuggestions');

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User get user => _user;
  String get userId => _userId;
  String get userMail => _mail;
  String get picture => _picture;

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future registerEmailPass(String email, String password) async {

    final User user = (await _auth.createUserWithEmailAndPassword(
        email: email, password: password)).user;
    notifyListeners();
    if (user != null) {
      return true;
    }
    else {
      return false;
    }
  }


  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
      _userId = firebaseUser.uid;
      _mail = firebaseUser.email;
      _picture = await getPicture();
    }
    notifyListeners();
  }

  Future<String> getPicture() async{
    return _savedSuggestions
        .doc(_userId)
        .get()
        .then((userId) => userId.data())
        .then((userInfo) => userInfo != null
        ? userInfo['picture'].toString()
        : "https://cdn.iconscout.com/icon/premium/png-512-thumb/anonymous-17-623658.png");
  }

  void setUserPicture(String path) async {
    // save locall path
    _picture = path;
    // push to cloud
    await _savedSuggestions.doc(_userId).set({'picture': path});
    notifyListeners();
  }

}