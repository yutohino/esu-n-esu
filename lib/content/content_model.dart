import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class ContentModel extends ChangeNotifier {
  Post post;
  AppUser user;

  ContentModel(this.post, this.user) {
    titleController.text = post.title;
    contentController.text = post.content;
    imageUrls = post.imageUrls;
  }

  bool isUploading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? title;
  String? content;
  List<String> imageUrls = [];

  Map<int, File> imageFiles = {};

  bool isUpdatedPost = false;
  bool isDeletedPost = false;

  Future reloadPost() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('posts').doc(post.id).get();
    post = Post(snapshot);
    isUpdatedPost = true;
    notifyListeners();
  }

  void deletePost() {
    isDeletedPost = true;
  }
}
