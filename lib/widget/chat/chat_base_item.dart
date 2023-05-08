import 'package:flutter/material.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatBaseItem extends StatelessWidget {
  final ChatItem data;
  final Widget content;

  const ChatBaseItem(
    this.data,
    this.content, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var channel = context.read<ChannelStore>().channel;
    bool isWhisper = data.messageType == MessageType.whisper;
    var firstUrl =
        MimeType.text == data.mimeType ? Util.getFirstUrl(data.message) : null;

    return Row(
      textDirection: data.isMe ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            if (!data.isMe) {
              Util.sendWhisperDialog(context, channel, data);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.profileNameCondition)
                Container(
                  width: 34,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(17),
                    ),
                    color: Color(0xffeaeaea),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(17),
                    ),
                    child: Image.asset(
                      "assets/profile/profile_img_${data.userInfo?['profile'].toString() ?? '1'}.png",
                    ),
                  ),
                ),
              if (!data.profileNameCondition) const SizedBox(width: 34),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: data.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (data.profileNameCondition || isWhisper) ...[
                      Padding(
                        padding: (isWhisper && data.isMe)
                            ? const EdgeInsets.only(right: 8)
                            : const EdgeInsets.only(left: 8),
                        child: Row(children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 150,
                            ),
                            child: Text(
                              data.nickName ?? '홍길동',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666),
                              ),
                            ),
                          ),
                          Text(
                            isWhisper
                                ? data.isMe
                                    ? '님에게'
                                    : '님이'
                                : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xff666666),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection:
                          data.isMe ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        content,
                        if (data.timeCondition && firstUrl == null) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            Util.getCurrentDate(data.messageDt).toString(),
                            style: const TextStyle(
                              color: Color(0xff666666),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
