import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:flutter_kakao/store/emoji_store.dart';
import 'package:flutter_kakao/store/player_store.dart';
import 'package:flutter_kakao/util/logger.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/chat/chat_top_date.dart';
import 'package:flutter_kakao/widget/chat/emoji_chat_item.dart';
import 'package:flutter_kakao/widget/chat/emoji_images.dart';
import 'package:flutter_kakao/widget/chat/emoji_list.dart';
import 'package:flutter_kakao/widget/chat/file_chat_item.dart';
import 'package:flutter_kakao/widget/chat/image_chat_item.dart';
import 'package:flutter_kakao/widget/chat/text_chat_item.dart';
import 'package:flutter_kakao/widget/chat/user_join_item.dart';
import 'package:flutter_kakao/widget/chat/user_leave_item.dart';
import 'package:flutter_kakao/widget/chat/video_chat_item.dart';
import 'package:flutter_kakao/widget/chat/whisper_chat_item.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:flutter_kakao/widget/common/heart_icon.dart';
import 'package:flutter_kakao/widget/drawer/right_drawer.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/constants.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late final Channel channel;
  late final PlayerStore playerStore;

  var inputController = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focus = FocusNode();
  var currentScrollPosition = false;
  var emojiActive = false;
  ChatRoomModel? roomInfo;
  TargetDrawer target = TargetDrawer.help;
  var rowHeight = 50.0;

  @override
  void initState() {
    channel = Provider.of<ChannelStore>(context, listen: false).channel!;
    playerStore = Provider.of<PlayerStore>(context, listen: false);
    VChatCloudApi.getRoomInfo(roomId: channel.roomId).then((value) {
      setState(() {
        roomInfo = value;
      });
    });
    inputController.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          rowHeight = rowKey.currentContext?.size?.height ?? 50.0;
        });
      });
    });
    _focus.onKey = (node, event) {
      if (event is RawKeyDownEvent && !Util.isMobile) {
        if (event.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
          return KeyEventResult.ignored;
        } else if (event.logicalKey.keyLabel == 'Enter') {
          sendMessage();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
    _scrollController.addListener(() {
      scrollController();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focus.dispose();
    channel.leave();
    super.dispose();
  }

  void scrollController() {
    if (_scrollController.offset <= 300) {
      setState(() {
        currentScrollPosition = false;
      });
    } else if (currentScrollPosition == false) {
      setState(() {
        currentScrollPosition = true;
      });
    }
  }

  void clientListHandler() {
    logger.d('client list clicked');
    setState(() {
      target = TargetDrawer.clientList;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void fileBoxHandler() {
    logger.d('file box clicked');
    setState(() {
      target = TargetDrawer.fileBox;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void helpHandler() {
    logger.d('help clicked');
    setState(() {
      target = TargetDrawer.help;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void backHandler() {
    Navigator.pop(context);
  }

  void fileUploadMethod() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    bool isDialogOpened = false;

    void dialog() async {
      isDialogOpened = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      isDialogOpened = false;
    }

    if (result != null && context.mounted) {
      dialog();

      try {
        var file = UploadFileModel(
          file: Util.isWeb ? null : File(result.files.single.path!),
          bytes: Util.isWeb ? result.files.single.bytes : null,
          name: Util.isWeb ? result.files.single.name : null,
        );
        await channel.sendFile(file);
        moveScrollBottom();
      } catch (e) {
        if (e is VChatCloudError) {
          Util.showToast(e.message);
        } else {
          logger.e(e);
        }
      } finally {
        if (context.mounted && isDialogOpened) {
          Navigator.pop(context);
        }
      }
    }
  }

  void uploadHandler() async {
    if (await Util.filePermissionCheck()) {
      fileUploadMethod();
    } else {
      var granted = await Util.requestFileWrite();
      if (granted) {
        uploadHandler();
      }
    }
  }

  void emojiHandler() {
    _focus.unfocus();
    setState(() {
      emojiActive = !emojiActive;
    });
  }

  void moveScrollBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(0);
    });
  }

  void unfocus() {
    _focus.unfocus();
    setState(() {
      emojiActive = false;
    });
  }

  void sendMessage() {
    if (!Util.isMobile) {
      _focus.requestFocus();
    }
    if (inputController.text.trim().isEmpty) return;

    channel.sendMessage(inputController.text);
    inputController.clear();

    moveScrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    var chatLog = Provider.of<ChannelStore>(context).chatLog;
    var clientList = Provider.of<ChannelStore>(context).clientList;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 50,
          titleTextStyle: const TextStyle(
            color: Color(0xff999999),
          ),
          iconTheme: const IconThemeData(
            color: Color(
              0xff666666,
            ),
          ),
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                iconSize: 20,
                alignment: Alignment.center,
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue.shade900,
                  size: 20,
                ),
                splashRadius: 20,
                onPressed: backHandler,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomInfo?.roomNm ?? "로딩중입니다...",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff666666),
                      ),
                    ),
                    Row(
                      children: [
                        Anchor(
                          onTap: clientListHandler,
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blue.shade800,
                                size: 14,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                clientList.length.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        const HeartIcon(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: 22,
              child: IconButton(
                onPressed: fileBoxHandler,
                iconSize: 18,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.inbox,
                ),
                splashRadius: 18,
              ),
            ),
            SizedBox(
              width: 22,
              child: IconButton(
                onPressed: helpHandler,
                iconSize: 18,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.help_outline,
                ),
                splashRadius: 18,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        endDrawer: RightDrawer(
          target: target,
        ),
        endDrawerEnableOpenDragGesture: false,
        body: Container(
          color: const Color(0xffdfe6f2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: unfocus,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      chatBuilder(chatLog),
                      if (currentScrollPosition)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: FloatingActionButton.small(
                            onPressed: () {
                              _scrollController.jumpTo(0);
                              setState(() {
                                currentScrollPosition = false;
                              });
                            },
                            tooltip: "Scroll to Bottom",
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              bottomBarBuilder(),
              if (emojiActive) emojiBuilder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget emojiBuilder() {
    var emoji = Provider.of<EmojiStore>(context);
    emoji.initEmojiList();
    emoji.initChildEmojiList();

    return Column(
      children: const [
        EmojiImages(),
        EmojiList(),
      ],
    );
  }

  Container bottomBarBuilder() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 30 * 1.5,
            child: IconButton(
              onPressed: uploadHandler,
              icon: const Icon(
                Icons.add,
                color: Color(0xffcccccc),
              ),
              iconSize: 20 * 1.5,
              splashRadius: 10 * 1.5,
            ),
          ),
          Flexible(
            child: TextField(
              key: rowKey,
              focusNode: _focus,
              controller: inputController,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              cursorColor: const Color(0xff2a61be),
              // textAlignVertical: TextAlignVertical.center,
              onTap: () {
                setState(() {
                  emojiActive = false;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            width: 32 * 1.3,
            child: IconButton(
              onPressed: emojiHandler,
              iconSize: 20 * 1.3,
              splashRadius: 18 * 1.3,
              color: (emojiActive) ? Colors.blue[700] : Colors.grey[500],
              icon: const Icon(Icons.emoji_emotions),
            ),
          ),
          Anchor(
            onTap: sendMessage,
            child: Container(
              width: 50,
              constraints: BoxConstraints(maxHeight: max(rowHeight, 50)),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 10,
              ),
              alignment: Alignment.bottomCenter,
              decoration: inputController.text.trim().isEmpty
                  ? const BoxDecoration(
                      color: Color(0xff919191),
                    )
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2A61BE),
                          Color(0xff5D48C6),
                        ],
                        transform: GradientRotation(pi * -0.25),
                      ),
                    ),
              child: Transform.rotate(
                angle: pi * -0.25,
                child: Icon(
                  Icons.send,
                  size: 25,
                  color: inputController.text.trim().isEmpty
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chatBuilder(List<ChatItem> chatLog) {
    bool isUnSupported = Util.isWeb ||
        (!Util.isWeb && Util.isWindows ||
            Util.isIOS ||
            Util.isMacOS ||
            Platform.isLinux ||
            Platform.isFuchsia);
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        reverse: true,
        child: Column(
          children: [
            ...chatLog.asMap().entries.expand(
              (entry) {
                var index = entry.key;
                var log = entry.value;
                FileModel? file;
                if (log.mimeType == MimeType.file) {
                  try {
                    if (log.message is String) {
                      file = FileModel.fromJson(json.decode(log.message)[0]);
                    } else {
                      file = FileModel.fromJson(log.message[0]);
                    }
                  } catch (e) {
                    if (log.message is String) {
                      file = FileModel.fromHistoryJson(
                          json.decode(log.message)[0]);
                    } else {
                      file = FileModel.fromHistoryJson(log.message[0]);
                    }
                  }
                }

                return [
                  if (index == 0) ...[
                    ChatTopDate(log),
                  ] else if (chatLog[index - 1]
                          .messageDt
                          .toIso8601String()
                          .substring(0, 10) !=
                      log.messageDt.toIso8601String().substring(0, 10)) ...[
                    SizedBox(
                        height: log.profileNameCondition ||
                                log.myProfileNameCondition ||
                                [
                                  MessageType.join,
                                  MessageType.leave,
                                  MessageType.notice
                                ].contains(log.messageType)
                            ? 20
                            : 8),
                    ChatTopDate(log),
                  ],
                  SizedBox(
                      height: log.profileNameCondition ||
                              log.myProfileNameCondition ||
                              [
                                MessageType.join,
                                MessageType.leave,
                                MessageType.notice
                              ].contains(log.messageType)
                          ? 20
                          : 8),
                  if (log.messageType == MessageType.join)
                    UserJoinItem(log)
                  else if (log.messageType == MessageType.leave)
                    UserLeaveItem(log)
                  else if (log.messageType == MessageType.notice)
                    const Text("공지")
                  else if (log.messageType == MessageType.whisper)
                    WhisperChatItem(
                      log,
                    )
                  else if (log.messageType == MessageType.custom)
                    const Text("커스텀")
                  else if (log.mimeType == MimeType.emojiImg)
                    EmojiChatItem(
                      log,
                    )
                  else if (file != null)
                    if (imgTypeList.contains(file.fileExt))
                      ImageChatItem(
                        log,
                        file: file,
                      )
                    else if (videoTypeList.contains(file.fileExt) &&
                        !isUnSupported)
                      VideoChatItem(
                        log,
                        isUnSupported,
                        file: file,
                      )
                    else
                      FileChatItem(
                        log,
                        file: file,
                      )
                  else
                    TextChatItem(
                      log,
                    ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
