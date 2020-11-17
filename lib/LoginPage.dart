import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/UserRepo.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final UserRepository user = Provider.of<UserRepository>(context, listen: true);
    final introTextField = Padding(padding: EdgeInsets.all(20.0),
        child:
        Text(
            "Welcome to Startup Names Generator, please log in below"
        ));

    final emailField = Padding(padding: EdgeInsets.all(20.0),
        child: TextField(
          controller: _email,
          obscureText: false,
          decoration: InputDecoration(
            labelText: "Email",
          ),
        ));

    final passwordField = Padding(padding: EdgeInsets.all(20.0),
        child: TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
          ),
        ));

    return ListView(
      children: <Widget>[
        SizedBox(height: 15.0),
        introTextField,
        emailField,
        passwordField,
        user.status == Status.Authenticating
        ? Consumer<UserRepository>(
          builder: (context, UserRepository user, _) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        )
        : Consumer<UserRepository>(
          builder: (context, UserRepository user, _) {
            return Padding(padding: EdgeInsets.all(20.0),
              child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.red,
              child: MaterialButton(
                minWidth: MediaQuery
                .of(context)
                .size
                .width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: () async {
                if (await user.signIn(_email.text, _password.text) == false) {
                  final snackBarLogin = SnackBar(
                    content: Text("There was an error logging into the app"),
                  );
                  Scaffold.of(context).showSnackBar(snackBarLogin);
                }
                else {
                  Navigator.of(context).pop(); // return to Main Page
                }
              },
              child: Text("Log in",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              ),
            ));
        },
       ),
        Padding(padding: EdgeInsets.all(20.0),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.teal,
            child: MaterialButton(
              minWidth: MediaQuery
                .of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: () async {
                showModalSheet();
              },
              child: Text("New user? Click to sign up",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        )
      ],
    );
  }

  Future<void> showModalSheet() {

    String error = '';
    final UserRepository user = Provider.of<UserRepository>(context, listen: false);
    final introTextField = Padding(padding: EdgeInsets.all(5.0),
        child: Text("Please confirm your password below:"));

    final WrongPassText = Padding(padding: EdgeInsets.all(5.0),
        child: Text(
            error,
            style: TextStyle(color: Colors.red),
        ));

    final passwordField = Padding(padding: EdgeInsets.all(5.0),
        child: TextFormField(
          controller: _confirmPass,
          validator: (val) => val != _password.text ? 'Passwords must match' : null,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
          ),
        ));

     return showModalBottomSheet<void>(
       context: context,
       isScrollControlled: true,
       builder: (BuildContext context) {
        // return Consumer<UserRepository>(
          //   builder: (context, UserRepository user, _) {
             return Container(
             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
             color: Colors.white,
             child: Form(
               key: _formKey,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 mainAxisSize: MainAxisSize.min,
                 children: <Widget>[
                   SizedBox(height: 15.0),
                   Center(child: introTextField),
                   Divider(
                     indent: 8,
                     endIndent: 8,
                   ),
                   passwordField,
                   WrongPassText,
                   Divider(
                     indent: 8,
                     endIndent: 8,
                   ),
                   SizedBox(height: 30.0),
                   Container(
                     color: Colors.teal,
                     child: FlatButton(
                       color: Colors.teal,
                       textColor: Colors.white,
                       padding: EdgeInsets.all(8.0),
                       splashColor: Colors.tealAccent,
                       onPressed: () async {
                         if (_formKey.currentState.validate()){
                           await user.registerEmailPass(_email.text, _password.text);
                           user.setUserPicture("https://cdn.iconscout.com/icon/premium/png-512-thumb/anonymous-17-623658.png");
                           Navigator.of(context).pop();
                           Navigator.of(context).pop();
                             // return to Main Page
                           }
                       },
                       child: Text(
                         "Confirm",
                         style: TextStyle(fontSize: 16.0),
                       ),
                     ),
                   ),
                   SizedBox(height: 15.0),
                 ],
               ),
             ),
           );
         //});
       },
     );

  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPass.dispose();
    super.dispose();
  }
}