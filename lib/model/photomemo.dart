enum PhotoSource { CAMERA, GALLERY }

class PhotoMemo {
  //keys for Firestore doc
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdby';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photofilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedwith';
  static const IMAGE_LABELS = 'imagelabels';
  static const COMMENTS = 'comments';
  static const NUM_COMMENTS = 'numComments';

  String? docId; //Firestore auto generated doc id
  late String createdBy; //email == user id
  late String title;
  late String name;
  late String memo;
  late String photoFilename; // image at Cloud Storage
  late String photoURL;
  DateTime? timestamp;
  late List<dynamic> sharedWith; // list of emails
  late List<dynamic> imageLabels; //ML image labels
  late List<dynamic> comments;
  late int numComments = 0;
  //Add Comment object; Comment includes user left by, message, etc.

  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.timestamp,
    List<dynamic>? sharedWith,
    List<dynamic>? imageLabels,
    List<dynamic>? comments,
  }) {
    this.sharedWith = sharedWith == null
        ? []
        : [...sharedWith]; //copies contents of sharedWith
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.comments = comments == null ? [] : [...comments];
  }

  PhotoMemo.clone(PhotoMemo p) {
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;
    this.sharedWith = [...p.sharedWith];
    this.imageLabels = [...p.imageLabels];
    this.comments = [...p.comments];
  }

  void assign(PhotoMemo p) {
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;
    this.sharedWith.clear();
    this.sharedWith.addAll(p.sharedWith);
    this.imageLabels.clear();
    this.imageLabels.addAll(p.imageLabels);
    this.comments.clear();
    this.comments.addAll(p.comments);
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      TIMESTAMP: this.timestamp,
      SHARED_WITH: this.sharedWith,
      IMAGE_LABELS: this.imageLabels,
      COMMENTS: this.comments,
    };
  }

  static PhotoMemo? fromFirestoreDoc({required Map<String, dynamic> doc, required String docId}) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }

    return PhotoMemo(
      docId: docId,
      createdBy: doc[CREATED_BY] ??= 'N/A',
      title: doc[TITLE] ??= 'N/A',
      memo: doc[MEMO] ??= 'N/A',
      photoFilename: doc[PHOTO_FILENAME] ??= 'N/A',
      photoURL: doc[PHOTO_URL] ??= 'N/A',
      sharedWith: doc[SHARED_WITH] ??= [],
      imageLabels: doc[IMAGE_LABELS] ??= [],
      comments: doc[COMMENTS] ??= [],
      timestamp: doc[TIMESTAMP] != null ?
        DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch)
        : DateTime.now(),

    );
  }

  static String? validateTitle(String? value) {
    return value == null || value.trim().length < 3 ? 'Title too short' : null;
  }

  static String? validateMemo(String? value) {
    return value == null || value.trim().length < 5 ? 'Memo too short' : null;
  }

  static String? validateSharedWith(String? value) {
    if (value == null || value.trim().length == 0) return null;

    List<String> emailList =
        value.trim().split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.'))
        continue;
      else
        return 'Invalid email list: comma or space separated list';
    }
  }
}
