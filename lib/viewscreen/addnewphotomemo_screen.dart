import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddNewPhotoMemoScreen extends StatefulWidget {

  static const routeName = '/addNewPhotoMemoScreen';
  late final User user;
  
  AddNewPhotoMemoScreen({required this.user});

  @override
  State<StatefulWidget> createState() {
    return _AddNewPhotoMemoState();
  }

}

class _AddNewPhotoMemoState extends State<AddNewPhotoMemoScreen> {

  late _Controller con;

  _AddNewPhotoMemoState() {
    con = _Controller(this);
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New PhotoMemo'),

      ),
      body: Text('user: ${widget.user.email}'),
    );
  }

}

class _Controller {
  late _AddNewPhotoMemoState state;
  _Controller(this.state);
}