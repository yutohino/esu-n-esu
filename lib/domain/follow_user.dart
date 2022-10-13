import 'package:cloud_firestore/cloud_firestore.dart';

class FollowUser {
  FollowUser(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    uid = data['uid'];
    followUserList = List.from(data['followList']);
  }

  String id = '';
  String uid = '';
  List<String> followUserList = [];
}
