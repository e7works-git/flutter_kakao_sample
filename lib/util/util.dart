import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:flutter_kakao/util/logger.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

final pathSeparator = Util.isWeb ? "/" : Platform.pathSeparator;

class Util {
  static final FToast _toast = FToast();

  static const String urlRegex =
      r"[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?";
  static const String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2), //default is 4s
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 파일 저장 전 쓰기 권한 요청
  static Future<bool> requestFileWrite() async {
    if (!await filePermissionCheck()) {
      var result = (await Permission.photos.request()).isGranted &&
          (await Permission.videos.request()).isGranted &&
          (await Permission.storage.request()).isGranted;
      if (!result) {
        showToast("미디어 접근 권한을 허용해주세요.");
        await Future.delayed(const Duration(seconds: 1));
        await openAppSettings();
      }
      return result;
    }
    return true;
  }

  static Future<bool> filePermissionCheck() async {
    if (Util.isAndroid) {
      bool storage = true;
      bool videos = true;
      bool photos = true;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      /// sdk버전33, 안드로이드 버전13 이상일 경우 저장소 정책 변경으로 다른 권한 요청
      if (androidInfo.version.sdkInt >= 33) {
        photos = await Permission.photos.status.isGranted;
        videos = await Permission.videos.status.isGranted;
      } else {
        storage = await Permission.storage.status.isGranted;
      }
      return androidInfo.version.sdkInt >= 33 ? photos && videos : storage;
    } else if (Util.isWeb) {
      return true;
    } else if (Util.isMacOS) {
      return true;
    } else {
      return await Permission.storage.status.isGranted;
    }
  }

  /// 저장소 읽기/쓰기 권한 필요
  ///
  /// `requestFileWrite` 메서드 먼저 사용
  static Future<String> getDownloadPath() async {
    if (Util.isWeb) {
      return Future.value('/');
    } else if (Util.isAndroid) {
      return Future.value('/storage/emulated/0/Download/');
    } else if (Util.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getDownloadsDirectory())!.path;
    }
  }

  static bool get isWeb => kIsWeb;

  /// android / ios = 모바일
  static bool get isMobile =>
      !Util.isWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isAndroid => !Util.isWeb && Platform.isAndroid;
  static bool get isIOS => !Util.isWeb && Platform.isIOS;
  static bool get isMacOS => !Util.isWeb && Platform.isMacOS;
  static bool get isWindows => !Util.isWeb && Platform.isWindows;

  /// toast 메시지 띄우기
  static void showToast(String message) {
    if (_toast.context == null && contextProvider.currentContext != null) {
      _toast.init(contextProvider.currentContext!);
    }

    _toast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.black.withOpacity(0.6),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      toastDuration: const Duration(milliseconds: 1500),
    );
  }

  static Future<dynamic> sendWhisperDialog(
    BuildContext context,
    Channel? channel,
    ChatItem data,
  ) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var store = Provider.of<ChannelStore>(context, listen: false);

        void submit() {
          if (controller.text.trim().isNotEmpty) {
            channel?.sendWhisper(
              controller.text,
              receivedClientKey: data.clientKey!,
            );
            store.addChatLog(
              ChatItem.fromJson({
                "message": controller.text,
                "nickName": data.nickName,
                "clientKey": channel!.user?.clientKey,
                "roomId": channel.roomId,
                "mimeType": "text",
                "messageType": "whisper",
                "userInfo": channel.user?.userInfo,
              }),
            );
            chatScreenKey.currentState?.moveScrollBottom();
            Navigator.pop(context);
          } else {
            Util.showToast("내용을 입력해주세요.");
          }
        }

        return AlertDialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          content: Material(
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 25,
                left: 25,
                right: 25,
                bottom: 15,
              ),
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(
                maxHeight: 180,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4dc9c9c9),
                    offset: Offset(1, 1.7),
                    blurRadius: 7,
                    spreadRadius: 0,
                  )
                ],
                color: Color(0xffffffff),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "${data.nickName}",
                          style: const TextStyle(
                            color: Color(0xff333333),
                            fontSize: 16.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const Text(
                        "님에게 귓속말",
                        style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: controller,
                          cursorColor: const Color(0xff2a61be),
                          decoration: const InputDecoration(
                            hintText: "내용을 입력하세요.",
                            contentPadding: EdgeInsets.all(0),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xff2a61be),
                                width: 2,
                              ),
                            ),
                            focusColor: Color(0xff2a61be),
                            hintStyle: TextStyle(
                              color: Color(0xffaaaaaa),
                              fontSize: 14,
                            ),
                          ),
                          onSubmitted: (text) => submit(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "취소",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: submit,
                        child: const Text(
                          "전송",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> openLink(String url) async {
    var uri = Uri.parse(url);
    var regex = RegExp(urlRegex);
    try {
      if (regex.hasMatch(url) && !url.contains(":")) {
        uri = Uri.parse("https://$url");
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      logger.e("링크를 열 수 없습니다.. ${uri.toString()}");
      return false;
    }
  }

  static Future<bool> openFile(FileModel file) async {
    if (Util.isWeb) {
      showToast("웹은 지원하지 않는 기능입니다.");
      return Future.value(false);
    }

    var path = await Util.getDownloadPath();
    var readyFile = File(
        "$path$pathSeparator${file.fileKey}_${file.originFileNm ?? file.fileNm}");
    if (!await readyFile.exists()) {
      Util.showToast("파일이 존재하지 않습니다");
      return false;
    } else {
      var result = await OpenFilex.open(readyFile.absolute.path);
      if (result.type != ResultType.done) {
        try {
          return await Util.openLink("file:${readyFile.absolute.path}");
        } catch (e) {
          Util.showToast("열 수 없는 파일입니다.");
          return false;
        }
      } else {
        return result.type == ResultType.done;
      }
    }
  }

  static String getSizedText(int fileSize) {
    if (fileSize > 1024 * 1024) {
      return "${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB";
    } else {
      return "${(fileSize / 1024).toStringAsFixed(2)}KB";
    }
  }

  static RegExpMatch? getFirstUrl(dynamic message) {
    return RegExp(urlRegex).firstMatch(message);
  }

  static String getCurrentDate(DateTime messageDt) {
    return intl.DateFormat("aa hh:mm", 'ko').format(messageDt);
  }
}

class DateUtil {
  DateTime currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minute;
  int? second;
  int? week;

  DateUtil() {
    year = currentTime.year;
    month = currentTime.month;
    day = currentTime.day;
    hour = currentTime.hour;
    minute = currentTime.minute;
    second = currentTime.second;
    week = DateUtil().getWeek(currentTime.weekday);
  }

  getWeek(int week) {
    switch (week) {
      case 0:
        return '월요일';
      case 1:
        return '화요일';
      case 2:
        return '수요일';
      case 3:
        return '목요일';
      case 4:
        return '금요일';
      case 5:
        return '토요일';
      case 6:
        return '일요일';
    }
  }

  setYYYYMMDDhhmmssToDate(String yyyyMMddHHmmss) {
    DateTime dateTime = DateTime.parse(
        '${yyyyMMddHHmmss.substring(0, 8)}T${yyyyMMddHHmmss.substring(8)}');
    year = dateTime.year;
    month = dateTime.month;
    day = dateTime.day;
    hour = dateTime.hour;
    minute = dateTime.minute;
    second = dateTime.second;
  }

  getChattingRoomTopDate() {
    return '$year년 $month월 $day일 $week';
  }
}
