import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirestoreController {

  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,

  }) async {
    DocumentReference ref = await FirebaseFirestore.instance.collection(Constant.PHOTOMEMO_COLLECTION)
      .add(photoMemo.toFirestoreDoc());
    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .where(PhotoMemo.CREATED_BY, isEqualTo: email)
      .orderBy(PhotoMemo.TIMESTAMP, descending: true)
      .get();

      var result = <PhotoMemo>[];
      querySnapshot.docs.forEach((doc) {
        if (doc.data() != null) {
          var document = doc.data() as Map<String, dynamic>;
          var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
          if (p != null) { //filter invalid photomemo doc in Firestore
            result.add(p);
          }
        }
      });
      return result;
  }
}