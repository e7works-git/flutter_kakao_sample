import 'package:flutter/material.dart';
import 'package:flutter_messenger/main.dart';
import 'package:flutter_messenger/store/channel_store.dart';
import 'package:flutter_messenger/store/emoji_store.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class EmojiList extends StatefulWidget {
  const EmojiList({data, super.key});

  @override
  State<EmojiList> createState() => _EmojiList();
}

class _EmojiList extends State<EmojiList> {
  final _scrollController = ScrollController();
  late Channel channel;

  @override
  void initState() {
    super.initState();
    channel = context.read<ChannelStore>().channel!;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var emojiChildUrlList = Provider.of<EmojiStore>(context).emojiChildUrlList;
    var selectedIndex = Provider.of<EmojiStore>(context).selectedIndex;

    // 75dp + 아이콘 간격 10dp + 컨테이너 패딩 15*2dp
    var limit = 85 * 5 + 30;
    var width = MediaQuery.of(context).size.width;
    var over = limit < width;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        var move = details.primaryVelocity ?? 0;
        if (move > 200) {
          Provider.of<EmojiStore>(context, listen: false)
              .setEmojiIndex(selectedIndex - 1);
        } else if (move < -200) {
          Provider.of<EmojiStore>(context, listen: false)
              .setEmojiIndex(selectedIndex + 1);
        }
      },
      child: Container(
        height: 283,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Scrollbar(
          controller: _scrollController,
          child: GridView.count(
            controller: _scrollController,
            padding: const EdgeInsets.all(15),
            crossAxisCount: over ? ((width - 30) ~/ 90).toInt() : 4,
            childAspectRatio: 1,
            mainAxisSpacing: 15,
            crossAxisSpacing: 10,
            children: List.generate(emojiChildUrlList.length, (index) {
              return Anchor(
                onTap: () {
                  channel.sendEmoji(
                      'img/emoticon/emo0${selectedIndex + 1}/emo0${selectedIndex + 1}_0${(index + 1).toString().padLeft(2, "0")}.png');
                  chatScreenKey.currentState?.moveScrollBottom();
                },
                child: Image.asset(
                  emojiChildUrlList[index],
                  fit: BoxFit.contain,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
