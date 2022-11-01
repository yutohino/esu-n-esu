import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    title = data['title'] ?? '';
    content = data['content'] ?? '';
    imageUrls = List.from(data['imageUrls'] ?? []);
    Timestamp? createdAtTimestamp = data['createdAt'];
    if (createdAtTimestamp != null) {
      createdAt = createdAtTimestamp.toDate();
    }
    Timestamp? editedAtTimestamp = data['editedAt'];
    if (editedAtTimestamp != null) {
      editedAt = editedAtTimestamp.toDate();
    }
    uid = data['uid'] ?? '';
    isEdited = data['isEdited'] ?? false;
  }

  String id = '';
  String title = '';
  String content = '';
  List<String> imageUrls = [];
  DateTime createdAt = DateTime(1900, 1, 1, 0, 0);
  DateTime editedAt = DateTime(1900, 1, 1, 0, 0);
  String uid = '';
  bool isEdited = false;
}
