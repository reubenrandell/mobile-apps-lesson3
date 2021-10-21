import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  final User user;
  late final String displayName;
  late final String email;
  final List<PhotoMemo> photoMemoList;

  UserHomeScreen({required this.user, required this.photoMemoList}) {
    displayName = user.displayName ?? 'N/A';
    email = user.email ?? 'no email';
  }

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false), //disable back button
      child: Scaffold(
          appBar: AppBar(
            title: Text('User Home'),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.displayName),
                  accountEmail: Text(widget.email),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out'),
                  onTap: con.signOut,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: con.addButton,
          ),
          body: widget.photoMemoList.length == 0
              ? Text(
                  'No PhotoMemo found!',
                  style: Theme.of(context).textTheme.headline6,
                )
              : ListView.builder(
                  itemCount: widget.photoMemoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: WebImage(
                        url: widget.photoMemoList[index].photoURL,
                        context: context,
                      ),
                      title: Text(widget.photoMemoList[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.photoMemoList[index].memo.length >= 40
                            ? widget.photoMemoList[index].memo.substring(0, 40) + '...'
                            : widget.photoMemoList[index].memo,
                          ),
                          Text('Created By: ${widget.photoMemoList[index].createdBy}'),
                          Text('SharedWith: ${widget.photoMemoList[index].sharedWith}'),
                          Text('Timestamp: ${widget.photoMemoList[index].timestamp}'),


                        ],
                      )
                    );
                  },
                )),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  _Controller(this.state);

  void addButton() async {
    await Navigator.pushNamed(
        //
        state.context,
        AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: state.widget.photoMemoList,
        });
      state.render((){});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('======= sign out error: $e');
    }
    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }
}
