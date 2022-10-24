import 'package:cloud_firestore/cloud_firestore.dart';

class FollowUsers {
  FollowUsers(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    followUsersIdList = List.from(data['followUsersIdList'] ?? []);
  }

  String id = '';
  List<String> followUsersIdList = [];
}
