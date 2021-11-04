class Comment {
  //keys for Firestore doc
  static const MESSAGE = 'message';
  static const CREATED_BY = 'createdby';
  //static const COMMENT_FILENAME = 'commentfilename';
  static const TIMESTAMP = 'timestamp';
  //static const SHARED_WITH = 'sharedwith';

  String? docId; //Firestore auto generated doc id
  late String createdBy; //email == user id
  late String message;
  late String commentFilename; // image at Cloud Storage; SO May not need this
  DateTime? timestamp;
  //late List<dynamic> sharedWith; // list of emails
  //Add Comment object; Comment includes user left by, message, etc.

  Comment({
    this.docId,
    this.createdBy = '',
    this.message = '',
    //this.commentFilename = '',
    this.timestamp,
    // List<dynamic>? sharedWith,
    // List<dynamic>? imageLabels,
  }) {
    // this.sharedWith = sharedWith == null
    //     ? []
    //     : [...sharedWith]; //copies contents of sharedWith
    // this.imageLabels = imageLabels == null ? [] : [...imageLabels];
  }

  Comment.clone(Comment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.message = c.message;
    //this.commentFilename = c.commentFilename;
    // this.photoURL = p.photoURL;
    this.timestamp = c.timestamp;
    // this.sharedWith = [...c.sharedWith];
    // this.imageLabels = [...c.imageLabels];
  }

  void assign(Comment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.message = c.message;
    // this.photoFilename = p.photoFilename;
    // this.photoURL = p.photoURL;
    this.timestamp = c.timestamp;
    // this.sharedWith.clear();
    // this.sharedWith.addAll(p.sharedWith);
    // this.imageLabels.clear();
    // this.imageLabels.addAll(p.imageLabels);
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      // TITLE: this.title,
      CREATED_BY: this.createdBy,
      MESSAGE: this.message,
      // PHOTO_FILENAME: this.photoFilename,
      // PHOTO_URL: this.photoURL,
      TIMESTAMP: this.timestamp,
      // SHARED_WITH: this.sharedWith,
      // IMAGE_LABELS: this.imageLabels,
    };
  }

  static Comment? fromFirestoreDoc({required Map<String, dynamic> doc, required String docId}) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }

    return Comment(
      docId: docId,
      createdBy: doc[CREATED_BY] ??= 'N/A',
      // title: doc[TITLE] ??= 'N/A',
      message: doc[MESSAGE] ??= 'N/A',
      // photoFilename: doc[PHOTO_FILENAME] ??= 'N/A',
      // photoURL: doc[PHOTO_URL] ??= 'N/A',
      // sharedWith: doc[SHARED_WITH] ??= [],
      // imageLabels: doc[IMAGE_LABELS] ??= [],
      timestamp: doc[TIMESTAMP] != null ?
        DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch)
        : DateTime.now(),

    );
  }

  // static String? validateTitle(String? value) {
  //   return value == null || value.trim().length < 3 ? 'Title too short' : null;
  // }

  static String? validateComment(String? value) {
    return value == null || value.trim().length < 1 ? 'Comment too short' : null;
  }

  String getMessage() {
    return message;
  }

  // static String? validateSharedWith(String? value) {
  //   if (value == null || value.trim().length == 0) return null;

  //   List<String> emailList =
  //       value.trim().split(RegExp('(,| )+')).map((e) => e.trim()).toList();
  //   for (String e in emailList) {
  //     if (e.contains('@') && e.contains('.'))
  //       continue;
  //     else
  //       return 'Invalid email list: comma or space separated list';
  //   }
  // }
}
