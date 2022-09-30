import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    title = data['title'];
    content = data['content'];
    imageUrls = List.from(data['imageUrls']);
    final createdAtTimestamp = data['createdAt'] as Timestamp;
    createdAt = createdAtTimestamp.toDate();
    final editedAtTimestamp = data['editedAt'] as Timestamp;
    editedAt = editedAtTimestamp.toDate();
    uid = data['uid'];
    isEdited = data['isEdited'];
    documentReference = doc.reference;
  }

  String? title;
  String? content;
  List<String>? imageUrls;
  DateTime? createdAt;
  DateTime? editedAt;
  String? uid;
  bool isEdited = false;
  DocumentReference? documentReference;
}
