import 'package:cloud_firestore/cloud_firestore.dart';

class FollowUsers {
  FollowUsers(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    uid = data['uid'] ?? '';
    followUsersUidList = List.from(data['followUsersUidList'] ?? []);
  }

  String id = '';
  String uid = '';
  List<String> followUsersUidList = [];
}
