import 'package:flutter/material.dart';
import 'package:flutter_messenger/vo/chat_item.dart';

class ChatTopDate extends StatelessWidget {
  final ChatItem data;
  const ChatTopDate(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dt = data.messageDt;
    List<String> weekend = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
    var currentDate =
        '${dt.year}년 ${dt.month}월 ${dt.day}일 ${weekend[dt.weekday - 1]}';

    return Container(
      width: 150,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color(0xffbec6d8),
      ),
      child: Text(
        currentDate,
        style: const TextStyle(
          color: Color(0xff333333),
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 12.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
