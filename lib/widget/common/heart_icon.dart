import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class HeartIcon extends StatefulWidget {
  const HeartIcon({super.key});

  @override
  State<HeartIcon> createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController ac;
  late int likeCount = 0;
  late final Timer refreshTimer;
  bool selected = false;
  Timer? timer;

  @override
  void initState() {
    ac = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
    );
    getLike();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        getLike();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    ac.dispose();
    refreshTimer.cancel();
    super.dispose();
  }

  void getLike() async {
    likeCount = await VChatCloudApi.getLike(roomId: roomId);
    setState(() {});
  }

  void addLike() async {
    likeCount = await VChatCloudApi.like(roomId: roomId);
    setState(() {});
  }

  void tapHandler() async {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }

    addLike();
    setState(() {
      selected = !selected;
    });
    timer = Timer(const Duration(milliseconds: 100), () {
      setState(() {
        selected = false;
      });
    });
  }

  String get countText {
    final unit = ['', 'K', 'M', 'B', 'T'];
    var count = likeCount.toDouble();
    var targetUnit = 0;
    while (count > 1000) {
      count = count / 1000;
      targetUnit++;
    }

    count = (count * 10).round() / 10;

    return "${count != count.toInt() ? count : count.toInt()}${unit[min(targetUnit, unit.length - 1)]}";
  }

  @override
  Widget build(BuildContext context) {
    return Anchor(
      onTap: tapHandler,
      child: Row(
        children: [
          AnimatedScale(
            scale: selected ? 3 : 1,
            duration: selected
                ? const Duration(milliseconds: 100)
                : const Duration(milliseconds: 600),
            curve: selected ? Curves.ease : Curves.bounceOut,
            child: Icon(
              Icons.favorite,
              color: Colors.red.shade700,
              size: 14,
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            countText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff999999),
            ),
          ),
        ],
      ),
    );
  }
}
