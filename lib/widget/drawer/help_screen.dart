import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late final ScrollController sc;

  @override
  void initState() {
    super.initState();
    sc = ScrollController();
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Scrollbar(
        controller: sc,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
          ),
          controller: sc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...sendMessage,
              const SizedBox(height: 30),
              ...sendEmoticon,
              const SizedBox(height: 30),
              ...sendWhisper,
              const SizedBox(height: 30),
              ...translate,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get sendMessage {
    return [
      makeTitle("메세지 보내기"),
      const SizedBox(height: 8),
      Image.asset(
        "assets/common/help_input.png",
        fit: BoxFit.fitWidth,
      ),
      const SizedBox(height: 8),
      Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "전송하실 메시지를 입력하고 "),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SvgPicture.asset(
                  "assets/common/help_send.svg",
                  width: 18,
                  height: 18,
                ),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            const TextSpan(text: "을 클릭하세요.")
          ],
        ),
        style: const TextStyle(
          color: Color(0xff333333),
          height: 1.5,
          fontSize: 14.0,
        ),
      ),
    ];
  }

  List<Widget> get sendEmoticon {
    return [
      makeTitle("이모티콘 보내기"),
      const SizedBox(height: 8),
      Image.asset(
        "assets/common/help_emoticon.png",
        fit: BoxFit.fitWidth,
      ),
      const SizedBox(height: 8),
      const Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "채팅방 입력창 우측 "),
            WidgetSpan(
              child: Icon(
                Icons.emoji_emotions,
                size: 16,
                color: Color(0xffcccccc),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(text: "을 클릭하시면 나타나는 목록에서 원하시는 이모티콘을 선택하세요.")
          ],
        ),
        style: TextStyle(
          color: Color(0xff333333),
          height: 1.5,
          fontSize: 14.0,
        ),
      ),
    ];
  }

  List<Widget> get sendWhisper {
    return [
      makeTitle("귓속말 보내기"),
      const SizedBox(height: 8),
      Image.asset(
        "assets/common/help_whisper.png",
        fit: BoxFit.fitWidth,
      ),
      const SizedBox(height: 8),
      const SizedBox(
        child: Text(
          "원하시는 상대의 대화명을 길게 누르면 나타나는 팝업창에 보내실 귓속말을 작성하고 전송을 클릭하세요.",
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xff333333),
            height: 1.5,
            fontSize: 14.0,
          ),
          softWrap: true,
        ),
      )
    ];
  }

  List<Widget> get translate {
    return [
      makeTitle("채팅 언어 번역하기"),
      const SizedBox(height: 8),
      Image.asset(
        "assets/common/help_lang_trans.png",
        fit: BoxFit.fitWidth,
      ),
      const SizedBox(height: 8),
      const Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                Icons.person,
                size: 14,
                color: Color(0xff6f87c6),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: " 클릭 후 참여자 목록에서 번역할 사용자의 번역 버튼을 클릭하고 팝업창에서 번역할 언어를 선택하세요.",
            ),
          ],
          style: TextStyle(
            color: Color(0xff333333),
            height: 1.5,
            fontSize: 14.0,
          ),
        ),
      ),
    ];
  }

  Container makeTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        color: Color(0xff6f87c6),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xfffefefe),
          fontSize: 14.0,
        ),
      ),
    );
  }
}
