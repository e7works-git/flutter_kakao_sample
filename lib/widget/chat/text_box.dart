import 'package:flutter/material.dart';
import 'package:flutter_messenger/util/util.dart';
import 'package:flutter_messenger/vo/chat_item.dart';
import 'package:flutter_messenger/widget/chat/open_graph_item.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class TextBox extends StatelessWidget {
  final ChatItem data;
  const TextBox(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    const regex = Util.urlRegex;
    final List<InlineSpan> texts = [];

    data.message.toString().splitMapJoin(RegExp(regex), onMatch: (m) {
      texts.add(
        WidgetSpan(
          child: Anchor(
            onTap: () => Util.openLink(m[0]!),
            child: Text(
              '${m[0]}',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
      return '';
    }, onNonMatch: (n) {
      texts.add(
        TextSpan(
          text: n,
          style: TextStyle(
            color: data.isDeleteChatting
                ? const Color(0xff999999)
                : const Color(0xff333333),
            fontWeight:
                data.isDeleteChatting ? FontWeight.w200 : FontWeight.normal,
            fontSize: 14.0,
          ),
        ),
      );
      return '';
    });
    var firstUrl = RegExp(regex).firstMatch(data.message);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!data.isMe)
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                left: !data.profileNameCondition ? 10 : 0,
              ),
              child: data.profileNameCondition
                  ? SvgPicture.asset(
                      (data.messageType == MessageType.whisper)
                          ? "assets/chat/whisper_box_arr_left.svg"
                          : "assets/chat/chatbox_arr_left.svg",
                      width: 8,
                      height: 10,
                    )
                  : null,
            ),
          ),
        Column(
          crossAxisAlignment:
              data.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.none,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(3),
                ),
                color: (data.messageType == MessageType.whisper)
                    ? Colors.yellow
                    : data.isMe
                        ? const Color(0xffb2c7eb)
                        : Colors.white,
              ),
              child: Text.rich(TextSpan(children: texts)),
            ),
            if (firstUrl != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                textDirection:
                    data.isMe ? TextDirection.ltr : TextDirection.rtl,
                children: [
                  if (data.timeCondition) ...[
                    Text(
                      textAlign: TextAlign.end,
                      Util.getCurrentDate(data.messageDt).toString(),
                      style: const TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                  OpenGraphItem(firstUrl.group(0)!)
                ],
              )
          ],
        ),
        if (data.isMe)
          Padding(
            padding: EdgeInsets.only(
              top: 5,
              left: !data.myProfileNameCondition ? 10 : 0,
            ),
            child: data.myProfileNameCondition
                ? SvgPicture.asset(
                    (data.messageType == MessageType.whisper)
                        ? "assets/chat/whisper_box_arr_right.svg"
                        : "assets/chat/chatbox_arr_right.svg",
                    width: 8,
                    height: 10,
                  )
                : null,
          ),
      ],
    );
  }
}
