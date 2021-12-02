import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class CommentScreen extends StatefulWidget {
  static const routeName = '/commentScreen';

  final PhotoMemo photoMemo;
  final User user;
  List<Comment> commentList; //Try making not final maybe?

  CommentScreen(
      {required this.photoMemo, required this.user, required this.commentList});

  @override
  State<StatefulWidget> createState() {
    return _CommentState();
  }
}

class _CommentState extends State<CommentScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    con.getListOfComments(); //testing this; may need to delete.
    return Scaffold(
        appBar: AppBar(
          title: Text('Comments'),
          // actions: [
          //   IconButton(
          //     onPressed: () => con.save,
          //     icon: Icon(Icons.check),
          //   ),
          // ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: widget.commentList.isEmpty
                ? Column(
                    children: [
                      Text(
                        'No Comments shared with me',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Comment'),
                        autocorrect: true,
                        //validator: PhotoMemo.validateTitle,
                        onSaved: con.saveComment,
                      ),
                      ElevatedButton(
                        onPressed:
                            con.save, //(widget.photoMemo), //SAVE FUNCTION
                        child: Text(
                          'Submit Comment',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      WebImage(
                        url: widget.photoMemo.photoURL,
                        context: context,
                        height: MediaQuery.of(context).size.height * 0.35,
                      ),
                      for (var comment in widget.commentList)
                        Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(comment.message),
                        ),
                      //Here, put text box for leaving comments
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Comment'),
                        autocorrect: true,
                        //validator: PhotoMemo.validateTitle,
                        onSaved: con.saveComment, //Save COMMENT FUNCTION
                      ),
                      ElevatedButton(
                        onPressed:
                            con.save, //(/*widget.photoMemo*/), //SAVE FUNCTION
                        child: Text(
                          'Submit Comment',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}

class _Controller {
  late _CommentState state;
  //late PhotoMemo tempMemo;
  Comment tempComment = Comment();
  late List<Comment> listOfComments;

  _Controller(this.state);

  getListOfComments(
    // PhotoMemo photoMemo,
  ) async {
    try {
      listOfComments = await FirestoreController.getPhotoMemoListComments(
          memoId: state.widget.photoMemo.docId!, email: state.widget.user.email!);
    } catch (e) {
      print(e);
      return;
    }
    state.widget.commentList = listOfComments;
    state.render(() {});
  }

  //other variables

  void saveComment(String? value) {
    //add comment to list
    if (value != null) {
      ////tempComment = Comment(message: value);
      //// commentList.add(value);
      //// tempMemo.comments.clear();

      tempComment.message = value;
      //state.widget.commentList.add(tempComment);
    }
  }

  void save() async {
    FormState? currentState = state.formKey.currentState;
    print('$currentState');
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    try {
      tempComment.memoId = state.widget.photoMemo.docId!;
      tempComment.createdBy = state.widget.user.email!;
      tempComment.sharedWith = state.widget.photoMemo.sharedWith;
      tempComment.sharedWith.add(tempComment.createdBy);
      tempComment.timestamp = DateTime.now();

      String docId = await FirestoreController.addComment(comment: tempComment);
      tempComment.docId = docId;
      state.widget.commentList.insert(0, tempComment);

      // Map<String, dynamic> updateInfo = {};
      // updateInfo[Comment.MESSAGE] = tempComment.message;
      // updateInfo[Comment.MEMO_ID] = photoMemo.docId;

      // if (updateInfo.isNotEmpty) {
      //   // changes have been made
      //   tempComment.timestamp = DateTime.now();
      //   updateInfo[Comment.TIMESTAMP] = tempComment.timestamp;
      //   await FirestoreController.addComment(
      //     comment: tempComment,
      //     // docId: tempComment.docId!,
      //     // updateInfo: updateInfo,
      //   );
      //state.widget.photoMemo.assign(tempMemo);

      // }
      Navigator.pop(state.context);
    } catch (e) {
      if (Constant.DEV) print('====== add comment error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'add comment error. $e',
      );
    }

    // state.render(() => {});
  }
}
