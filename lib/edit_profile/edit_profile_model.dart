import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/AppUser.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileModel extends ChangeNotifier {
  EditProfileModel(this.user) {
    username = user.username;
    userDetail = user.userDetail;
    usernameController.text = user.username;
    userDetailController.text = user.userDetail;
  }

  AppUser user;

  String username = '';
  String userDetail = '';
  final usernameController = TextEditingController();
  final userDetailController = TextEditingController();

  bool isLoading = false;

  final imagePicker = ImagePicker();
  File? editedImageFile;

  void startUploading() {
    isLoading = true;
    notifyListeners();
  }

  void endUploading() {
    isLoading = false;
    notifyListeners();
  }

  void setUsername(String username) {
    this.username = username;
    notifyListeners();
  }

  void setUserDetail(String userDetail) {
    this.userDetail = userDetail;
    notifyListeners();
  }

  Future pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      editedImageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future saveEditedProfile() async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.id);
    // ユーザー画像に変更があればStorageから削除およびアップロードを行う
    String? newUserImageUrl;
    if (editedImageFile != null) {
      if (user.userImageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(user.userImageUrl).delete();
        } on FirebaseException catch (e) {
          print("Failed with error '${e.code}': ${e.message}");
        }
      }
      final task = await FirebaseStorage.instance
          .ref('users/${doc.id}${editedImageFile.hashCode}')
          .putFile(editedImageFile!);
      newUserImageUrl = await task.ref.getDownloadURL();
    }

    // Firestoreに更新したプロフィールをアップロード
    await doc.update({
      'username': username,
      'userDetail': userDetail,
      'userImageUrl': newUserImageUrl,
    });
  }

  Future deleteMyAccount() async {
    // TODO: 削除処理を記述
  }
}
