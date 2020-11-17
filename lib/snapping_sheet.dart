import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'UserRepo.dart';

class MySnappingSheet extends StatefulWidget {
  @override
  _MySnappingSheetState createState() => _MySnappingSheetState();
}

class _MySnappingSheetState extends State<MySnappingSheet> with SingleTickerProviderStateMixin{

  var _controller = SnappingSheetController();
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);
    final sheet_pushed = false;
    String _mail = user.userMail;
    return SnappingSheet(
      snappingSheetController: _controller,
      snapPositions: const [
        SnapPosition(positionPixel: 0.0, snappingCurve: Curves.easeIn, snappingDuration: Duration(seconds: 1)),
        SnapPosition(positionFactor: 0.3),
      ],
      grabbingHeight: 50,
      grabbing: InkWell(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey),
          child: Center(

            child: ListTile(
              title: Text(
                  "Welcome back, $_mail",
              ),
              trailing: Icon(
                  sheet_pushed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: Colors.black
              ),
            ),
          ),
        ),
        onTap: (){
          setState(() {
            _controller.snapPositions.last != _controller.currentSnapPosition
                ? _controller.snapToPosition(_controller.snapPositions.last)
                : _controller.snapToPosition(_controller.snapPositions.first);
          });
        },
      ),
      sheetBelow: SnappingSheetContent(
          child: ProfileSheet()
      ),
    );
  }
}

class ProfileSheet extends StatefulWidget {
  @override
  _ProfileSheetState createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);
    String _mail = user.userMail;
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                child: Wrap(
                  children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text('$_mail',
                            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.4)
                        ),
                      ),
                      FlatButton(
                        height: 2.0,
                        color: Colors.teal,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.tealAccent,
                        onPressed: () {
                          _getPictureFromUser();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 0.0),
                          child: Text(
                            "Change avatar",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      )
                    ],

                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getPictureFromUser() async {

    FilePickerResult result = await FilePicker.platform.pickFiles();
    final UserRepository user = Provider.of<UserRepository>(context);

    if(result != null){
      File picture = File(result.files.single.path);
      FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
      await _firebaseStorage.ref('${user.userId}.img').putFile(picture);
      user.setUserPicture(await _firebaseStorage.ref('${user.userId}.img').getDownloadURL());
    }
    else{
      // user didnt picked a file
      final fileSnackBar = SnackBar(content: Text('No image selected'));
      Scaffold.of(context).showSnackBar(fileSnackBar);
    }

  }

}

class ProfileImage extends StatefulWidget {
  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(
            user.picture
          )
        ),
      ),
      //margin: const EdgeInsets.all(2.0),
      width: 60.0,
      height: 60.0,
    );
  }
}
