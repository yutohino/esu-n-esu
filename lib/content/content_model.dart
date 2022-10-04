import 'dart:io';

import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class ContentModel extends ChangeNotifier {
  final Post post;

  ContentModel(this.post) {
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
}
