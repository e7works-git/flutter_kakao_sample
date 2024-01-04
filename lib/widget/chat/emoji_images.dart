import 'package:flutter/material.dart';
import 'package:flutter_messenger/store/emoji_store.dart';
import 'package:provider/provider.dart';

class EmojiImages extends StatefulWidget {
  const EmojiImages({super.key});

  @override
  State<EmojiImages> createState() => _EmojiImages();
}

class _EmojiImages extends State<EmojiImages> {
  late final ScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void changeSelectedIndex(int index) {
    Provider.of<EmojiStore>(context, listen: false).setEmojiIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    var emoji = Provider.of<EmojiStore>(context);
    var selectedIndex = emoji.selectedIndex;
    var emojiUrlList = emoji.emojiUrlList;

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xffebebeb),
        border: Border(
          bottom: BorderSide(color: Color(0xffcccccc)),
        ),
      ),
      child: Scrollbar(
        controller: _sc,
        child: ListView.separated(
          controller: _sc,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 6,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: emojiUrlList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Provider.of<EmojiStore>(context, listen: false)
                    .setEmojiIndex(index);
              },
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: selectedIndex == index ? Colors.white : null,
                  border: Border.all(
                    color: selectedIndex == index
                        ? const Color(0xffe3e3e3)
                        : Colors.white.withOpacity(0),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Image.asset(
                  selectedIndex == index
                      ? emojiUrlList[index].replaceAll("_off", "_on")
                      : emojiUrlList[index],
                  fit: BoxFit.fitWidth,
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            width: 20,
          ),
        ),
      ),
    );
  }
}
