import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    title = data['title'];
    content = data['content'];
    imageUrls = List.from(data['imageUrls']);
    final timestamp = data['createdAt'] as Timestamp;
    createdAt = timestamp.toDate();
    documentReference = doc.reference;
  }

  String? title;
  String? content;
  List<String>? imageUrls;
  DateTime? createdAt;
  DocumentReference? documentReference;
}
