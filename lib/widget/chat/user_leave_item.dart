import 'package:flutter/widgets.dart';
import 'package:flutter_messenger/vo/chat_item.dart';

class UserLeaveItem extends StatelessWidget {
  final ChatItem data;
  const UserLeaveItem(this.data, {super.key});

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
                color: Color(0xffff5a5a),
                fontSize: 14.0,
              ),
            ),
          ),
          const Text(
            "님이 나갔습니다.",
            style: TextStyle(
              color: Color(0xffff5a5a),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
