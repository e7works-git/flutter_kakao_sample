import 'package:flutter/material.dart';
import 'package:flutter_messenger/store/channel_store.dart';
import 'package:flutter_messenger/util/util.dart';
import 'package:flutter_messenger/vo/chat_item.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatBaseItem extends StatefulWidget {
  final ChatItem data;
  final Widget content;

  const ChatBaseItem(
    this.data,
    this.content, {
    super.key,
  });

  @override
  State<ChatBaseItem> createState() => _ChatBaseItemState();
}

class _ChatBaseItemState extends State<ChatBaseItem> {
  @override
  Widget build(BuildContext context) {
    var channel = context.read<ChannelStore>().channel;
    bool isWhisper = widget.data.messageType == MessageType.whisper;
    var firstUrl = MimeType.text == widget.data.mimeType
        ? Util.getFirstUrl(widget.data.message)
        : null;

    return Row(
      textDirection: widget.data.isMe ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            if (!widget.data.isMe && !widget.data.isDeleteChatting) {
              Util.chatLongPressDialog(context, channel, widget.data)
                  .then((_) => setState(() {}));
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.data.profileNameCondition)
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
                      "assets/profile/profile_img_${widget.data.userInfo?['profile'].toString() ?? '1'}.png",
                    ),
                  ),
                ),
              if (!widget.data.profileNameCondition) const SizedBox(width: 34),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: widget.data.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.data.profileNameCondition || isWhisper) ...[
                      Padding(
                        padding: (isWhisper && widget.data.isMe)
                            ? const EdgeInsets.only(right: 8)
                            : const EdgeInsets.only(left: 8),
                        child: Row(children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 150,
                            ),
                            child: Text(
                              widget.data.nickName ?? '홍길동',
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
                                ? widget.data.isMe
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
                      textDirection: widget.data.isMe
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        widget.content,
                        if (widget.data.timeCondition && firstUrl == null) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            Util.getCurrentDate(widget.data.messageDt)
                                .toString(),
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
