import 'package:flutter/material.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/chat/chat_base_item.dart';

class EmojiChatItem extends StatelessWidget {
  const EmojiChatItem(
    this.data, {
    super.key,
  });
  final ChatItem data;

  @override
  Widget build(BuildContext context) {
    return ChatBaseItem(
      data,
      Container(
        margin: data.isMe ? null : const EdgeInsets.only(left: 8),
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 150,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          'assets/${data.message}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
