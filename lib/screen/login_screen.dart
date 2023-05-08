import 'package:flutter/material.dart';
import 'package:flutter_kakao/custom_handler.dart';
import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/screen/footer.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:flutter_kakao/store/user_store.dart';
import 'package:flutter_kakao/util/logger.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  late TextEditingController loginController;
  late ScrollController _scrollController;

  final int minImageIndex = 1;
  final int maxImageIndex = 48;
  DateTime? ctime;
  int? imageIndex;
  Image? selectedImage;
  late final SharedPreferences storage;

  @override
  void initState() {
    super.initState();
    loginController = TextEditingController();
    loginController.addListener(() {
      setState(() {});
    });
    _scrollController = ScrollController();
    SharedPreferences.getInstance().then((value) {
      storage = value;
      setState(() {
        loginController.text = storage.getString("nickName") ?? '';
        imageIndex = storage.getInt("imageIndex") ?? 1;
        selectedImage = Image.asset(
          'assets/profile/profile_img_${imageIndex.toString()}.png',
          fit: BoxFit.cover,
        );
      });
    });
  }

  @override
  void dispose() {
    loginController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void changeImage(direction) {
    setState(() {
      if (direction == 'left') {
        if (imageIndex == minImageIndex) {
          imageIndex = maxImageIndex;
        } else {
          imageIndex = imageIndex! - 1;
        }
      } else {
        if (imageIndex == maxImageIndex) {
          imageIndex = minImageIndex;
        } else {
          imageIndex = imageIndex! + 1;
        }
      }
      selectedImage = Image.asset(
        'assets/profile/profile_img_${imageIndex.toString()}.png',
        fit: BoxFit.cover,
      );
    });
  }

  void goLogin() async {
    if (loginController.text.trim().isEmpty) {
      Util.showSnackBar(context, '이름을 입력해주세요.');
    } else {
      var channelStore = Provider.of<ChannelStore>(context, listen: false);
      var nickName = loginController.text.trim();
      if (storage.getString("clientKey") == null) {
        storage.setString("clientKey", Util.getRandomString(10));
      }
      var clientKey = storage.getString("clientKey");
      var user = UserModel(
        roomId: roomId,
        nickName: nickName,
        userInfo: {"profile": imageIndex.toString()},
        clientKey: clientKey,
      );
      storage.setString("nickName", user.nickName);
      storage.setInt("imageIndex", imageIndex ?? 1);

      try {
        channelStore.setChannel(
          await VChatCloud.connect(CustomHandler()),
        );

        var history = await channelStore.channel!.join(user);
        if (context.mounted) {
          var userStore = Provider.of<UserStore>(context, listen: false);
          userStore.name = nickName;
          userStore.changeIconIndex(imageIndex);

          // 히스토리 내용 추가
          List<ChatItem> list = [];
          list.addAll((history.body["history"] as List<dynamic>)
              .reversed // 역순으로 추가
              .map((e) => ChatItem.fromJson(e as Map<String, dynamic>)));
          var channelStore = Provider.of<ChannelStore>(context, listen: false);
          channelStore.setChatLog(list);

          Navigator.pushNamed(context, "/chat_screen");
        }
      } catch (e) {
        VChatCloud.disconnect();
        if (e is VChatCloudError) {
          Util.showToast(e.message);
        } else if (e is Error) {
          logger.e("$e ${e.stackTrace}");
          Util.showToast("알 수 없는 오류로 접속에 실패했습니다.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (ctime == null ||
            now.difference(ctime!) > const Duration(seconds: 2)) {
          ctime = now;
          Util.showSnackBar(context, '한 번더 누르시면 앱이 종료됩니다.');
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff2a61be),
                    Color(0xff5d48c6),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /* logo */
                            SizedBox(
                              width: 200,
                              child: Image.asset(
                                'assets/common/logo_noSquare.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            /* title */
                            Container(
                              margin: const EdgeInsets.only(
                                top: 22,
                                bottom: 95,
                              ),
                              child: const Text(
                                "사용하실 프로필 이미지와 이름을 입력하세요",
                                style: TextStyle(
                                  color: Color(0x80ffffff),
                                  fontSize: 14.0,
                                ),
                              ),
                            ),

                            /* loginBG Area */
                            Container(
                              width: 280,
                              height: 200,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x4cc9c9c9),
                                    offset: Offset(1, 1.73),
                                    blurRadius: 7,
                                    spreadRadius: 0,
                                  )
                                ],
                                color: Color(0xffffffff),
                              ),
                              child: Column(
                                children: [
                                  /* input line */
                                  Column(
                                    children: [
                                      Container(
                                        height: 30,
                                        margin: const EdgeInsets.only(
                                          left: 35,
                                          right: 35,
                                          top: 75,
                                        ),
                                        alignment: Alignment.topLeft,
                                        child: TextField(
                                          controller: loginController,
                                          maxLength: 8,
                                          scrollPadding: const EdgeInsets.only(
                                            bottom: 120,
                                          ),
                                          keyboardType: TextInputType.text,
                                          onSubmitted: (value) =>
                                              goLogin(), //키보드로 엔터 클릭 시 호출,
                                          style: const TextStyle(
                                            color: Color(0xff333333),
                                            fontSize: 14,
                                          ),
                                          cursorColor: const Color(0xff2a61be),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xffeeeeee),
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xffeeeeee),
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xff2a61be),
                                                width: 2,
                                              ),
                                            ),
                                            focusColor: Color(0xff2a61be),
                                            hintText: '이름을 입력하세요 (최대 8자)',
                                            hintStyle: TextStyle(
                                              color: Color(0xffaaaaaa),
                                              fontSize: 14,
                                            ),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      /* login btn */
                                      Anchor(
                                        onTap: goLogin,
                                        child: Container(
                                          width: 200,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25),
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff2a61be),
                                                Color(0xff5d48c6)
                                              ],
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '로그인',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /* profile Image Area */
                        Positioned(
                          bottom: 200 - (110 / 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Anchor(
                                onTap: () => changeImage('left'),
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    'assets/common/arr_left.png',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  var dx = details.velocity.pixelsPerSecond.dx;
                                  if (dx > 300) {
                                    changeImage('left');
                                  } else if (dx < -300) {
                                    changeImage('right');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffeaeaea),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: ClipOval(
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(48),
                                      child: selectedImage,
                                    ),
                                  ),
                                ),
                              ),
                              Anchor(
                                onTap: () => changeImage('right'),
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    'assets/common/arr_right.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(bottom: 0, child: FooterArea()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
