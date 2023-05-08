import 'package:flutter/material.dart';

class EmojiStore extends ChangeNotifier {
  /// 현재 선택된 이모지 종류의 index 값
  int selectedIndex = 0;

  /// 이모지 종류 개수
  final int maxIndex = 7;

  /// 이모지 종류 목록
  List<String> emojiUrlList = [];

  /// 선택된 이모지 종류의 파일 목록
  List<String> emojiChildUrlList = [];

  /// 각각 이모지 파일의 개수
  final List<int> eachEmojiList = [20, 18, 12, 20, 18, 10, 24];

  setEmojiIndex(int index) {
    if (index < 0) {
      selectedIndex = eachEmojiList.length - 1;
    } else if (index > eachEmojiList.length - 1) {
      selectedIndex = 0;
    } else {
      selectedIndex = index;
    }
    initChildEmojiList();
    notifyListeners();
  }

  void initEmojiList() {
    emojiUrlList = [
      for (var i = 0 + 1; i < maxIndex + 1; i++)
        'assets/img/emoticon/listImage/emo0${i.toString()}_ico_off.png',
    ];
  }

  void initChildEmojiList() {
    var currentIndex = selectedIndex + 1;
    emojiChildUrlList = [
      for (var i = 0 + 1; i < eachEmojiList[selectedIndex] + 1; i++)
        'assets/img/emoticon/emo0${currentIndex.toString()}/emo0${currentIndex.toString()}_0${i.toString().padLeft(2, "0")}.png',
    ];
  }

  void reset() {
    selectedIndex = 0;
    emojiUrlList.clear();
    emojiChildUrlList.clear();
    notifyListeners();
  }
}
