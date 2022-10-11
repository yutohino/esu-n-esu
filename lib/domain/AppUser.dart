import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    uid = data['uid'];
    email = data['email'];
    username = data['username'];
    userImageUrl = data['userImageUrl'] ?? '';
    userDetail = data['userDetail'] ?? '';
  }

  String uid = '';
  String email = '';
  String username = '';
  String userImageUrl = '';
  String userDetail = '';
}
