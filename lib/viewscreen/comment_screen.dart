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

  CommentScreen({required this.photoMemo, required this.user});

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
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: widget.photoMemo.comments.isEmpty
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
                      onSaved: (String? value) {
                        con.saveComment(value, widget.photoMemo.comments);
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => con.save(widget.photoMemo),
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
                    for (var comment in widget.photoMemo.comments)
                      Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(comment.message as String),
                      ),
                    //Here, put text box for leaving comments
                    TextFormField(
                      decoration: InputDecoration(hintText: 'Title'),
                      autocorrect: true,
                      //validator: PhotoMemo.validateTitle,
                      onSaved: (String? value) {
                        con.saveComment(value, widget.photoMemo.comments);
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => con.save(widget.photoMemo),
                      child: Text(
                        'Submit Comment',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ],
                ),
        ));
  }
}

class _Controller {
  late _CommentState state;
  late PhotoMemo tempMemo;
  late Comment tempComment;

  //other variables
  _Controller(this.state);

  void saveComment(String? value, List<dynamic> commentList) async {
    //add comment to list
    if (value != null) {
    } else
      return;
    //tempComment = Comment(message: value);
    commentList.add(Comment(message: value));
    tempMemo.comments.clear();
    tempMemo.comments.addAll(commentList);
  }

  void save(PhotoMemo photoMemo) async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    try {
      Map<String, dynamic> updateInfo = {};
      updateInfo[PhotoMemo.COMMENTS] = tempMemo.comments;

      if (updateInfo.isNotEmpty) {
        // changes have been made
        tempMemo.timestamp = DateTime.now();
        updateInfo[PhotoMemo.TIMESTAMP] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
          docId: tempMemo.docId!,
          updateInfo: updateInfo,
        );
        state.widget.photoMemo.assign(tempMemo);
      }
    } catch (e) {
      if (Constant.DEV) print('====== update photomemo error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update PhotoMemo error. $e',
      );
    }
  }
}
