import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/comment_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList;
  final User user;

  SharedWithScreen({required this.photoMemoList, required this.user});

  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Shared With ${widget.user.email}'),
        ),
        body: SingleChildScrollView(
          child: widget.photoMemoList.isEmpty
              ? Text(
                  'No PhotoMemos shared with me',
                  style: Theme.of(context).textTheme.headline6,
                )
              : Column(
                  children: [
                    for (var photoMemo in widget.photoMemoList)
                      Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WebImage(
                                url: photoMemo.photoURL,
                                context: context,
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              Text(
                                photoMemo.title,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(photoMemo.memo),
                              Text('Created by: ${photoMemo.createdBy}'),
                              Text('Created at: ${photoMemo.timestamp}'),
                              Text('Shared With: ${photoMemo.sharedWith}'),
                              Text('Image Labels: ${photoMemo.imageLabels}'),
                              IconButton(
                                  onPressed: () => con.comments(photoMemo),
                                  icon: Icon(Icons.comment)),
                            ],
                          )),
                  ],
                ),
        ));
  }
}

class _Controller {
  late _SharedWithState state;
  _Controller(this.state);

  void comments(PhotoMemo photoMemo) async {
    try {
      List<Comment> commentList =
          await FirestoreController.getPhotoMemoListComments(
              memoId: photoMemo.docId!);
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
