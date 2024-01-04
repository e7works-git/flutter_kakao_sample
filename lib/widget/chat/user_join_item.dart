import 'package:flutter/widgets.dart';
import 'package:flutter_messenger/vo/chat_item.dart';

class UserJoinItem extends StatelessWidget {
  final ChatItem data;
  const UserJoinItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "${data.nickName}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff6f87c6),
                fontSize: 14.0,
              ),
            ),
          ),
          const Text(
            "님이 입장하셨습니다.",
            style: TextStyle(
              color: Color(0xff6f87c6),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
