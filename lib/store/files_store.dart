import 'package:flutter/material.dart';
import 'package:vchatcloud_flutter_sdk/constants.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class FileStore extends ChangeNotifier {
  List<FileModel> list = [];
  final List<FileModel> imageList = [];
  final List<FileModel> videoList = [];
  final List<FileModel> fileList = [];

  void init(List<FileModel> allFileList) {
    if (list.length != allFileList.length) {
      list = allFileList;
      imageList.clear();
      videoList.clear();
      fileList.clear();

      for (var file in list) {
        var ext = file.fileExt?.toLowerCase();
        if (imgTypeList.contains(ext)) {
          imageList.add(file);
        } else if (videoTypeList.contains(ext)) {
          videoList.add(file);
        } else {
          fileList.add(file);
        }
      }
      notifyListeners();
    }
  }

  addImageList(FileModel file) {
    imageList.add(file);
    notifyListeners();
  }

  addVideoList(FileModel file) {
    videoList.add(file);
    notifyListeners();
  }

  addFileList(FileModel file) {
    fileList.add(file);
    notifyListeners();
  }

  reset() {
    list.clear();
    imageList.clear();
    videoList.clear();
    fileList.clear();
    notifyListeners();
  }
}
