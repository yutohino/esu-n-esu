// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileModel extends ChangeNotifier {
  AppUser user;

  EditProfileModel(this.user) {
    username = user.username;
    userDetail = user.userDetail;
    usernameController.text = user.username;
    userDetailController.text = user.userDetail;
  }

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
    if (pickedFile == null) {
      return;
    }
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'トリミング',
          toolbarColor: Colors.orange,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'トリミング',
        ),
      ],
    );

    if (croppedFile == null) {
      return;
    }
    // 圧縮処理
    final file = File(croppedFile.path);
    int dataSize = _getFileSize(file);
    Uint8List? result;
    if (dataSize > 1000) {
      result = await compressImage(file.path, 70);
    } else if (dataSize > 500) {
      result = await compressImage(file.path, 80);
    } else if (dataSize > 100) {
      result = await compressImage(file.path, 90);
    }
    if (result != null) {
      file.writeAsBytesSync(result);
    }

    editedImageFile = file;
    notifyListeners();
  }

  int _getFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    int sizeInMb = (sizeInBytes / (1024)).floor();
    return sizeInMb;
  }

  Future<Uint8List?> compressImage(String filePath, int qualityPercent) async {
    return await FlutterImageCompress.compressWithFile(filePath,
        minWidth: 480,
        minHeight: 480,
        quality: qualityPercent,
        keepExif: false);
  }

  Future saveEditedProfile() async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.id);
    // ユーザー画像に変更があればStorageから削除およびアップロードを行う
    String newUserImageUrl = '';
    if (editedImageFile != null) {
      if (user.userImageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(user.userImageUrl).delete();
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
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user.id)
        .orderBy('editedAt', descending: true)
        .get();
    // 投稿したポストを全て削除
    final batch = FirebaseFirestore.instance.batch();
    snapshots.docs.map((document) {
      batch.delete(document.reference);
    }).toList();
    await batch.commit();

    // 投稿したポストの画像を全て削除
    await Future.wait(snapshots.docs.map((document) async {
      final post = Post(document);
      for (String imageUrl in post.imageUrls) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
    }).toList());

    await FirebaseFirestore.instance.collection('follow').doc(user.id).delete();

    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.id)
        .delete();

    // アカウント情報とユーザー画像を削除する
    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
    if (user.userImageUrl.isNotEmpty) {
      await FirebaseStorage.instance.refFromURL(user.userImageUrl).delete();
    }
    await FirebaseAuth.instance.currentUser!.delete();
  }
}
