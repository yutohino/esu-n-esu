import 'package:cloud_firestore/cloud_firestore.dart';

class FollowUser {
  FollowUser(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    id = doc.id;
    uid = data['uid'];
    followUserUidList = List.from(data['followUserUidList']);
  }

  String id = '';
  String uid = '';
  List<String> followUserUidList = [];
}
