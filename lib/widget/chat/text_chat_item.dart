import 'package:flutter/material.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/chat/chat_base_item.dart';
import 'package:flutter_kakao/widget/chat/text_box.dart';

class TextChatItem extends StatelessWidget {
  final ChatItem data;
  const TextChatItem(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBaseItem(
      data,
      TextBox(data),
    );
  }
}
