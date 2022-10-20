import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmarks {
  Bookmarks(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    bookmarksDocIdList = List.from(data['bookmarksDocIdList'] ?? []);
  }

  String id = '';
  List<String> bookmarksDocIdList = [];
}
