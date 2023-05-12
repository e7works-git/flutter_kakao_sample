import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/chat/chat_base_item.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:flutter_kakao/widget/common/text_middle_ellipsis.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class FileChatItem extends StatefulWidget {
  final ChatItem data;
  final FileModel file;
  const FileChatItem(
    this.data, {
    super.key,
    required this.file,
  });

  @override
  State<FileChatItem> createState() => _FileChatItemState();
}

class _FileChatItemState extends State<FileChatItem> {
  bool fileExist = false;

  @override
  void initState() {
    Util.getDownloadPath().then((path) {
      if (Util.isWeb) {
        return Future.value(false);
      } else {
        var checkFile = File(
            "$path$pathSeparator${widget.file.fileKey}_${widget.file.originFileNm}");
        return checkFile.exists();
      }
    }).then((exist) {
      if (exist) {
        setState(() {
          fileExist = true;
        });
      }
    });
    super.initState();
  }

  Future<void> download(BuildContext context) async {
    var granted = await Util.requestFileWrite();
    if (granted) {
      Util.showToast("파일을 저장중입니다.");

      await VChatCloudApi.download(
        file: widget.file,
        downloadPath: await Util.getDownloadPath(),
      );

      Util.showToast("파일이 저장되었습니다.");
      setState(() {
        fileExist = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String sizeText = Util.getSizedText(widget.file.fileSize);
    return ChatBaseItem(
      widget.data,
      Container(
        width: 200,
        height: 90,
        margin: widget.data.isMe
            ? const EdgeInsets.only(right: 10)
            : const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: const Icon(
                Icons.file_copy,
                opticalSize: 30,
                color: Color(0xffcccccc),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 46,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextMiddleEllipsis(
                            widget.file.originFileNm!,
                            style: const TextStyle(
                              color: Color(0xff333333),
                              fontSize: 14.0,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "유효기간 : ~ ${widget.file.expire}",
                            style: const TextStyle(
                              color: Color(0xff666666),
                              fontSize: 10.0,
                            ),
                          ),
                          Text(
                            "용량 : $sizeText",
                            style: const TextStyle(
                              color: Color(0xff666666),
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Anchor(
                      onTap: () async {
                        if (fileExist) {
                          await Util.openFile(widget.file);
                          setState(() {});
                        } else {
                          download(context);
                        }
                      },
                      child: Text(
                        fileExist ? "열기" : "저장",
                        style: const TextStyle(
                          color: Color(0xff2a5da9),
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
