import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/comment_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
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
  GlobalKey<FormState> formKey = GlobalKey();

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
            actions: [
              con.delIndexes.isEmpty
                  ? Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Search (empty for all)',
                              fillColor: Theme.of(context).backgroundColor,
                              filled: true,
                            ),
                            autocorrect: true,
                            onSaved: con.saveSearchKey,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: con.cancelDelete,
                    ),
              con.delIndexes.isEmpty
                  ? IconButton(onPressed: con.search, icon: Icon(Icons.search))
                  : IconButton(onPressed: con.delete, icon: Icon(Icons.delete)),
            ],
            // title: Text('User Home'),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.displayName),
                  accountEmail: Text(widget.email),
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Shared With'),
                  onTap: con.sharedWith,
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
          body: con.photoMemoList.isEmpty
              ? Text(
                  'No PhotoMemo found!',
                  style: Theme.of(context).textTheme.headline6,
                )
              : ListView.builder(
                  itemCount: con.photoMemoList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: con.delIndexes.contains(index)
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: ListTile(
                        leading: WebImage(
                          url: con.photoMemoList[index].photoURL,
                          context: context,
                        ),
                        trailing: Stack(
                          children: [
                            // Icon(Icons.circle),

                            Icon(Icons.arrow_right),
                          ],
                        ),
                        title: Text(con.photoMemoList[index].title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              con.photoMemoList[index].memo.length >= 40
                                  ? con.photoMemoList[index].memo
                                          .substring(0, 40) +
                                      '...'
                                  : con.photoMemoList[index].memo,
                            ),
                            Text(
                                'Created By: ${con.photoMemoList[index].createdBy}'),
                            Text(
                                'SharedWith: ${con.photoMemoList[index].sharedWith}'),
                            Text(
                                'Timestamp: ${con.photoMemoList[index].timestamp}'),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () =>
                                        con.comments(con.photoMemoList[index]),
                                    icon: Icon(Icons.comment)),
                                Text(
                                  '${con.photoMemoList[index].numComments.toString()}',
                                  style: TextStyle(
                                    color: Colors.red[800],
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => con.onTap(index),
                        onLongPress: () => con.onLongPress(index),
                      ),
                    );
                  },
                )),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> delIndexes = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    for (int index = 0; index < photoMemoList.length; index++) {
      getNumComments(index);
    }
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWith(
              email: state.widget.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.PhotoMemoList: photoMemoList,
            ARGS.USER: state.widget.user,
          });
      if (Constant.DEV) print('========== sharedWith error: PAST SECOND LINE');
      Navigator.of(state.context).pop();
    } catch (e) {
      if (Constant.DEV) print('==++===== sharedWith error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedWith list: $e',
      );
    }
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort(); // ascending order
    for (int i = delIndexes.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[delIndexes[i]];
        await FirestoreController.deletePhotoMemo(photoMemo: p);
        await CloudStorageController.deletePhotoFile(photoMemo: p);
        state.render(() {
          photoMemoList.removeAt(delIndexes[i]);
        });
      } catch (e) {
        if (Constant.DEV) print('======== failed to delete photomemo: $e');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Failed to delete Photomemo: $e',
        );
        break; // quit further processing
      }
    }
    MyDialog.circularProgressStop(state.context);
    state.render(() => delIndexes.clear());
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().toLowerCase());
      }
    }
    MyDialog.circularProgressStart(state.context);
    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        // read all photomemos
        results = await FirestoreController.getPhotoMemoList(
            email: state.widget.email);
      } else {
        results = await FirestoreController.searchImages(
          createdBy: state.widget.email,
          searchLabels: keys,
        );
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() {
        photoMemoList = results;
        for (int index = 0; index < photoMemoList.length; index++) {
          getNumComments(index);
        }
      });
    } catch (e) {
      if (Constant.DEV) print('===== search error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Search error: $e',
      );
    }
  }

  void onTap(int index) async {
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
    //rerender home screen
    state.render(() {
      //reorder based on updated timestamp
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; //descending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
  }

  void addButton() async {
    await Navigator.pushNamed(
        //
        state.context,
        AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {});
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

  void getNumComments(int index) async {
    // var returnText = '0';
    // List<Comment> commentsList =
    //     await FirestoreController.getPhotoMemoListComments(
    //         memoId: photoMemoList[index].docId!);
    await FirestoreController.getPhotoMemoListComments(
            memoId: photoMemoList[index].docId!, email: state.widget.user.email!)
        .then(
      (value) {
        photoMemoList[index].numComments = value.length;
      },
    );
    // return commentsList.length.toString();

    // if (returnText == null) {
    //   returnText = '0';
    // }
    state.render(() {});
  }

  void comments(PhotoMemo photoMemo) async {
    try {
      List<Comment> commentList =
          await FirestoreController.getPhotoMemoListComments(
              memoId: photoMemo.docId!, email: state.widget.user.email!);
      print('${photoMemo.docId}');
      await Navigator.pushNamed(state.context, CommentScreen.routeName,
          arguments: {
            ARGS.USER: state.widget.user,
            ARGS.OnePhotoMemo: photoMemo,
            ARGS.CommentList: commentList,
          });
    } catch (e) {
      if (Constant.DEV) print('==++===== Comments Screen error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get Comments list: $e',
      );
    }
    state.render(() {});
  }
}
