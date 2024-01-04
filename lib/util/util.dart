import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/main.dart';
import 'package:flutter_messenger/store/channel_store.dart';
import 'package:flutter_messenger/util/logger.dart';
import 'package:flutter_messenger/vo/chat_item.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';
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
  static void showToast(String message, {int timeout = 1500}) {
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
      toastDuration: Duration(milliseconds: timeout),
    );
  }

  static Future<dynamic> showTermsDialog(
    BuildContext context,
  ) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
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
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                child: ListView(
                  children: const [
                    Text(
                      "사용자 이용약관",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      """


제1조 [목적]

이세븐웍스 주식회사(이하 “회사”)가 제공하는 서비스(이하 “vchatcloud”)를 이용해 주셔서 감사합니다.

이 약관은 “회사”가 제공하는 "vchatcloud" 서비스의 이용과 관련하여 회사와 이용자 간의 권리와 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

여러분은 이 약관에 동의함으로써 “vchatcloud”에 가입하여 서비스를 이용할 수 있습니다.

제2조 [용어의 정의]

이 약관에서 사용하는 용어의 정의는 다음과 같습니다.

1. vchatcloud : “회사”의 서비스명으로 "이용자"가 접속하여 “이용자”의 "고객"이 "채팅"서비스를 이용할 수 있도록 해 주는 솔루션

2. 이용자 : “vchatcloud”을 이용하고자 “회사”와 “vchatcloud” 이용계약(회원가입)을 체결한 고객 또는 고객사

3. 고객 : "이용자"가 제공하는 "채팅" 서비스를 제공 받는 자

4. 아이디(ID) : “이용자”의 식별과 “vchatcloud” 이용을 위하여 “이용자”가 정하고 “회사”가 승인하는 문자와 숫자의 조합

5. 비밀번호 : “이용자”가 정보 보호를 위해 정한 문자와 숫자 등의 조합

6. 채팅 : “이용자”의 “고객”이 문자 기반으로 이루어진 대화 내용을 채팅창에서 주고 받는 것

7. 이용계약 : “vchatcloud”을 이용하기 위하여 “회사”와 “이용자”간에 체결되는 계약

8. 해지 : “회사”와 “이용자”간 체결되어 있는 이용계약을 해약하는 것

9. 데이터 : “vchatcloud” 솔루션을 통해 게시 또는 전송되는 글, 사진, 영상, 파일, 기타 일체의 정보 혹은 콘텐츠

제3조 [약관의 게시와 개정]

1. 회사는 이 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 초기 화면에 게시합니다.

2. 회사는 "약관의 규제에 관한 법률", "정보통신망 이용촉진 및 정보보호 등에 관한 법률(이하 ‘정보통신망법’)", "전자상거래 등에서의 소비자보호에 관한 법률" 등 관련법을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다.

3. 회사가 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 제1항의 방식에 따라 개정약관의 적용일자 7일 전부터 적용일자 전까지 공지하거나, 이용자가 등록한 전자우편(e-mail) 등을 이용하여 통지합니다. 다만, 이용자에게 불리하게 약관의 내용을 변경하는 경우에는 최소한 30일 이상의 유예기간을 두고 공지합니다.

4. 회사가 전항에 따라 개정약관을 공지하면서 이용자에게 약관 변경 적용일까지 거부의사를 표시하지 않으면 동의한 것으로 본다는 뜻을 명확하게 공지하였음에도 이용자가 명시적으로 거부의 의사표시를 하지 아니한 경우 이용자가 개정약관에 동의한 것으로 봅니다.

5. 이용자가 개정약관의 적용에 동의하지 않을 경우 이용자는 이용계약을 해지하거나, 약관 철회 요청을 할 수 있습니다. 다만, 기존 약관을 적용할 수 없는 특별한 사정이 있는 경우에는 회사는 이용계약을 해지할 수 있습니다.

6. 이용자는 약관의 변경에 대하여 주의의무를 다하여야 하며 변경된 약관으로 인한 이용자의 피해는 회사가 책임지지 않습니다.

7. 이 약관에 명시되지 않은 사항에 대해서는 관계법령 및 회사가 제공하는 부가서비스에 관한 별도의 약관, 이용규정 등에 따릅니다.

제4조 [이용계약 체결]

1. 이용계약은 이용자가 되고자 하는 자(이하 "가입 신청자")가 홈페이지(https://vchatcloud.com)의 가입 절차에 따라 필수 입력사항을 기재한 후에 약관의 내용에 대하여 동의를 한 다음 회원가입 신청을 하고, 회사가 이 신청을 승낙함으로써 체결됩니다.

2. 회사는 가입 신청자의 신청에 대하여 특별한 사유가 없는 한 “vchatcloud” 이용을 승낙합니다. 다만, 회사는 다음 각 호에 해당하는 경우 이용 신청에 대하여는 승낙을 하지 않거나 유보할 수 있습니다.

 - 가입 신청자가 이 약관에 의하여 이전에 이용자가 이용자격을 상실한 적이 있는 경우, 단 회사의 재가입 승낙을 얻은 경우에는 예외로 함.

 - 실명이 아니거나 타인의 명의를 이용한 경우

 - 허위의 정보를 기재하거나, 회사가 제시하는 내용을 기재하지 않은 경우

 - 만 14세 미만의 가입 신청자인 경우, 단 회사가 요청하는 소정의 법정대리인(부모) 동의 절차를 거치는 경우에는 예외로 함.

 - 가입 신청자가 “vchatcloud”의 정상적인 제공을 저해하거나 다른 이용자의 “vchatcloud” 이용에 지장을 줄 것으로 예상되는 경우

 - 가입 신청자의 귀책사유로 인하여 승인이 불가능하거나 기타 규정한 제반 사항을 위반하며 신청하는 경우

 - 기타 회사가 관련법령 등을 기준으로 하여 명백하게 사회질서 및 미풍양속에 반할 우려가 있음을 인정하는 경우

 - 회사가 제공하는 모든 “vchatcloud” 서비스 중 어느 하나에 대하여 제15조 [계약 해지] 제2항에 의하여 회사로부터 회원 자격을 상실한 적이 있는 경우

3. 제1항에 따른 신청에 있어 회사는 가입 신청자의 실명 확인을 위하여 전문기관을 통하여 실명인증을 할 수 있습니다.

4. 회사는 “vchatcloud” 관련 설비의 여유가 없거나 기술상 또는 업무상 문제가 있는 경우에는 승낙을 유보할 수 있습니다.

5. 회사는 가입 신청에 대해 회사정책에 따라 등급별로 구분하여 이용시간, 이용횟수, “vchatcloud” 서비스 메뉴 등을 세분하여 이용에 차등을 둘 수 있습니다.

6. 회사는 “vchatcloud”의 고유 개발 등의 특별한 이용에 관한 계약은 별도 계약을 통하여 제공합니다.

제5조 [개인정보 수집 및 위탁]

1. 회사는 적법하고 공정한 수단에 의하여 이용계약의 성립 및 이행에 필요한 최소한의 개인정보를 수집합니다.

2. 회사는 개인정보의 수집 시 관련법규에 따라 개인정보 처리방침에 그 수집범위 및 목적을 사전 고지합니다.

3. 이용자는 vchatcloud 사용에 필요한 최소한의 개인정보를 회사에 위탁할 수 있습니다.

8. 회사를 통한 재위탁의 경우 이용자는 승인을 받아야 하며, 이 경우에도 이용자의 개인정보 취급(처리)방침의 수탁업체 목록 내에 반영하여야 합니다.

제6조 [개인정보보호 의무]

회사는 「정보통신망법」 및 「개인정보보호법」 등 관계 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력합니다. 개인정보의 보호 및 사용에 대해서는 관련법 및 회사의 개인정보 처리방침이 적용됩니다.

제7조 [이용자의 아이디 및 비밀번호의 관리에 대한 의무]

1. 이용자의 아이디와 비밀번호에 관한 관리책임은 이용자에게 있으며 이를 제3자가 이용하도록 하여서는 안 됩니다.

2. 회사는 이용자의 아이디가 개인정보 유출 우려가 있거나 반사회적 또는 미풍양속에 어긋나거나 회사 및 회사의 운영자로 오인할 우려가 있는 경우 해당 아이디의 활용을 제한할 수 있습니다.

3. 이용자는 아이디 및 비밀번호가 도용되거나 제3자가 사용하고 있음을 인지한 경우에는 이를 즉시 회사에 통지하고 회사의 안내에 따라야 합니다.

4. 제3항의 경우에 해당 이용자가 회사에 그 사실을 통지하지 않거나 통지한 경우에도 회사의 안내에 따르지 않아 발생한 불이익에 대하여 회사는 책임지지 않습니다.

제8조 [이용자정보의 변경]

1. 이용자는 개인정보 관리 화면을 통하여 언제든지 본인의 개인정보를 열람하고 수정할 수 있습니다. 다만, “vchatcloud” 서비스 관리를 위해 필요한 아이디 등은 원칙적으로 수정이 불가능하나, 부득이한 사유로 변경하고자 하는 경우에는 회사에 사유를 충분히 전달하여야 합니다.

2. 이용자는 회원가입 신청 시 기재한 사항이 변경되었을 경우 사이트에 접속하여 변경사항을 수정하여야 합니다.

3. 제2항의 변경사항을 수정하지 않아 발생한 불이익에 대하여 회사는 책임지지 않습니다.

제9조 [이용자에 대한 통지]

1. 회사가 이용자에 대한 통지를 하는 경우 이 약관에 별도 규정이 없는 한 이용자가 등록한 이메일, 문자 메시지 등으로 통지할 수 있습니다.

2. 회사는 전체 또는 불특정 다수 이용자에 대한 통지를 하는 경우 7일 이상 회사의 홈페이지 등에 게시함으로써 제1항의 통지에 갈음할 수 있습니다.

제10조 [회사의 의무]

1. 회사는 관련법과 이 약관이 금지하거나 미풍양속에 반하는 행위를 하지 않으며, 지속적이고 안정적으로 “vchatcloud” 서비스를 제공하기 위하여 최선을 다하여 노력합니다.

2. 회사는 이용자가 안전하게 “vchatcloud”을 이용할 수 있도록 개인정보 보호를 위해 보안시스템을 갖추어야 하며 개인정보 처리방침을 공시하고 준수합니다.

3. 회사는 “vchatcloud” 제공과 관련하여 알고 있는 이용자의 개인정보를 본인의 승낙 없이 제3자에게 누설, 배포하지 않습니다. 다만, 관계법령에 의한 관계기관으로부터의 요청 등 법률의 규정에 따른 적법한 절차에 의한 경우에는 그러하지 않습니다.

4. 회사는 “vchatcloud” 제공 목적에 맞는 “vchatcloud” 이용 여부를 확인하기 위하여 상시적으로 모니터링을 실시합니다.

5. 회사는 이용자에게 제공하는 유·무료 “vchatcloud” 서비스를 지속적이고 안정적으로 제공하기 위하여 설비에 장애가 발생하는 경우 지체 없이 이를 복구할 수 있도록 최선의 노력을 다하여야 합니다. 다만, 천재지변이나 비상사태 등 부득이한 경우에는 서비스를 일시 중단할 수 있습니다.

6. 회사는 서비스와 관련한 이용자의 불만사항이 접수되는 경우 이를 즉시 처리하여야 하며, 즉시 처리가 곤란한 경우 그 사유와 처리 일정을 서비스 또는 전자우편(e-mail)을 통하여 회원에게 통지하여야 합니다.

제11조 [이용자의 의무]

1. 이용자는 다음 행위를 하여서는 안 됩니다.

 - 신청 또는 변경 시 허위내용을 등록하는 행위

 - 타인의 정보를 도용하는 행위

 - 다른 이용자의 개인정보를 동의 없이 수집, 저장, 공개하는 행위

 - 회사가 게시한 정보를 변경하거나 제3자에게 제공하는 행위

 - 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해 행위

 - 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위

 - 외설 또는 폭력적인 메시지, 팩스, 음성, 메일, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시하는 행위

 - 회사의 동의 없이 영리를 목적으로 서비스를 사용하는 행위

 - 타인의 의사에 반하는 내용을 지속적으로 전송하는 행위

 - 범죄행위를 목적으로 하거나 범죄행위를 교사하는 행위

 - 선량한 풍속 또는 기타 사회질서를 해치는 행위

 - 현행 법령, 회사가 제공하는 “vchatcloud”에 정한 약관, 이용안내 및 “vchatcloud”과 관련하여 공지한 주의사항, 회사가 통지하는 사항, 기타 “vchatcloud” 이용에 관한 규정을 위반하는 행위

 - “vchatcloud”의 안정적인 운영에 지장을 주거나 줄 우려가 있는 일체의 행위

 - 제3자에게 임의로 “vchatcloud”을 임대하는 행위

 - 기타 불법적이거나 부당한 행위

2. 이용자는 「정보통신망법」 제44조의 7(불법정보의 유통금지 등) 규정에 따라 다음 각 호의 내용을 직접 발송하거나 “고객”이 발송하도록 방조해서는 안 된다.

 - 음란한 부호·문언·음향·화상 또는 영상을 배포·판매·임대하거나 공공연하게 전시하는 내용의 정보

 - 사람을 비방할 목적으로 공공연하게 사실이나 거짓의 사실을 드러내어 타인의 명예를 훼손하는 내용의 정보

 - 공포심이나 불안감을 유발하는 부호·문언·음향·화상 또는 영상을 반복적으로 상대방에게 도달하도록 하는 내용의 정보

 - 정당한 사유 없이 정보통신시스템, 데이터 또는 프로그램 등을 훼손·멸실·변경·위조하거나 그 운용을 방해하는 내용의 정보

 - 「청소년보호법」에 따른 청소년유해매체물로서 상대방의 연령 확인, 표시의무 등 법령에 따른 의무를 이행하지 아니하고 영리를 목적으로 제공하는 내용의 정보

 - 법령에 따라 금지되는 사행행위에 해당하는 내용의 정보

- 법령에 따라 분류된 비밀 등 국가기밀을 누설하는 내용의 정보

- 「국가보안법」에서 금지하는 행위를 수행하는 내용의 정보

- 그 밖에 범죄를 목적으로 하거나 교사(敎唆) 또는 방조하는 내용의 정보

 - 스팸메시지, 문자 피싱메시지 전송 등 불법행위

3. 회사는 이용자가 제1항, 제2항의 행위를 하는 경우 이용자의 “vchatcloud” 이용을 정지하고 일방적으로 계약을 해지할 수 있습니다.

4. 이용자는 「정보통신망법」의 광고성 정보 전송 시 의무사항(고객의 명시적 사전 동의 포함) 및 회사의 이용약관을 준수하여야 합니다.

5. 제2항의 사항과 같이 불법행위를 하거나 「전기통신사업법」 등 관련 법령을 준수하지 않아 발생하는 모든 민·형사 상의 책임은 이용자가 부담합니다.

6. 회사는 이용자가 본인 명의가 아닌 타인의 개인정보를 부정하게 사용하는 경우에 “vchatcloud”의 전부 또는 일부의 이용을 제한할 수 있습니다. 단, 회사는 “vchatcloud” 서비스 차단 후 지체 없이 차단 사실을 이용자에게 통지합니다.

7. 제6항의 경우, 회사는 차단된 “vchatcloud” 서비스에 관한 자료(변작된 유저식별번호, 차단시각, 전송자명 등)를 1년간 보관, 관리하고 이를 한국인터넷진흥원 등 관계기관에 제출할 수 있습니다.

8. 이용자는 회원가입 시 부정가입 방지를 위해 회사가 제공하는 본인인증방법으로 본인인증을 거친 후 “vchatcloud”을 이용하여야 합니다.

제12조 [“vchatcloud” 제공]

1. 회사는 이용자에게 아래와 같은 “vchatcloud” 서비스를 제공합니다.

 - vchatcloud 개설 및 관리

 - 고객 채팅 서비스

 - 채팅 서비스 페이지

 - 채팅방 모니터링 서비스 페이지

 - vchatcloud 기능 설정 서비스 페이지

 - 기타 회사가 추가 개발하거나 다른 회사와의 제휴계약 등을 통해 이용자에게 제공하는 일체의 서비스

2. 이용자는 “vchatcloud”의 서비스 상품 등급에 따라 사용기능이 다릅니다.

3. 회사는 제공하는 “vchatcloud” 서비스 중 일부에 대한 이용 가능 시간을 별도로 정할 수 있으며, 이 경우 사전에 이용자에게 공지합니다.

4. “vchatcloud” 서비스는 회사 혹은 “채널” 서비스의 업무상 또는 특별한 지장이 없는 한 연중무휴, 하루 이십사(24) 시간 가능한 것을 원칙으로 합니다. 단, 정기점검 등의 사유로 서비스 중단이 필요한 경우 회사는 이용자에게 사전 고지 또는 합의를 거쳐 지정된 기간 동안 서비스를 중단할 수 있으며 회사가 예측할 수 없는 사유로 긴급점검 등 서비스 제공을 중단한 경우에는 선조치 후에 공지할 수 있습니다.

5. 회사는 “vchatcloud”의 제공에 필요한 경우 정기점검을 실시할 수 있으며 정기점검시간은 “vchatcloud” 서비스화면에 공지한 바에 따릅니다.

제13조 [“vchatcloud”의 변경]

1. 회사는 상당한 이유가 있는 경우에 운영상, 기술상의 필요에 따라 제공하고 있는 전부 또는 일부 “vchatcloud” 서비스를 변경할 수 있습니다.

2. “vchatcloud” 서비스의 내용, 이용방법, 이용시간에 대하여 변경이 있는 경우에는 변경사유, 변경될 “vchatcloud” 서비스의 내용 및 제공일자 등을 변경 전에 “vchatcloud” 서비스 초기화면에 게시하여야 합니다.

3. 회사는 무료로 제공되는 “vchatcloud”의 일부 또는 전부를 회사의 정책 및 운영의 필요상 수정, 중단, 변경할 수 있으며 이에 대하여 관련법에 특별한 규정이 없는 한 이용자에게 별도의 보상을 하지 않습니다.

제14조 [“vchatcloud” 이용의 제한 및 정지]

1. 회사는 이용자가 이 약관 및 운영방침의 의무를 위반하거나 “vchatcloud”의 정상적인 운영을 방해한 경우 “vchatcloud” 이용을 제한하거나 정지할 수 있습니다.

2. 회사는 전항에도 불구하고 「주민등록법」을 위반한 명의도용 및 결제도용, 저작권법을 위반한 불법프로그램의 제공 및 운영방해, 「정보통신망법」을 위반한 스팸메시지 및 불법통신, 해킹, 악성프로그램의 배포, 접속권한 초과행위 등과 같이 관련법을 위반한 경우에는 즉시 영구이용정지를 할 수 있습니다. 본 항에 따른 “vchatcloud” 서비스 이용정지 시 “vchatcloud” 내의 톡캐시, 데이터, 혜택 및 권리 등도 모두 소멸되며 회사는 이에 대해 별도로 보상하지 않습니다.

3. 회사는 이용자가 다음 중 하나에 해당하는 경우 1개월 동안의 기간을 정하여 “vchatcloud”의 이용을 정지 할 수 있습니다.

 - 방송통신위원회ㆍ한국인터넷진흥원ㆍ과학기술정보통신부 등 관계기관이 스팸메시지ㆍ문자피싱메시지 등 불법행위의 전송사실을 확인하여 이용정지를 요청하는 경우

 - 이용자가 전송하는 광고로 인하여 회사의 “vchatcloud” 제공에 장애를 야기하거나 야기할 우려가 있는 경우

 - 이용자가 전송하는 메시지로 인하여 고객에게 피해가 발생하여 신고가 들어온 경우

 - 이용자에게 제공하는 “vchatcloud”이 스팸 및 불법정보로 이용되고 있는 경우

 - 이용자가 제11조 [이용자의 의무] 제6항을 위반하여 유저식별번호를 변작하는 등 거짓으로 표시한 경우

 - 과학기술정보통신부장관 또는 한국인터넷진흥원 등 관련 기관이 유저식별번호 변작 등을 확인하여 이용 정지를 요청하는 경우

4. 회사는 이용자의 정보가 부당한 목적으로 사용되는 것을 방지하고 보다 원활한 “vchatcloud” 서비스 제공을 위하여 12개월 이상 계속해서 로그인을 포함한 “vchatcloud” 이용이 없는 아이디를 휴면아이디로 분류하고 “vchatcloud” 이용을 정지할 수 있습니다.

5. 휴면아이디로 분류되기 30일 전까지 전자우편 등으로 휴면아이디로 분류된다는 사실, 일시 및 개인정보 항목을 이용자에게 통지합니다. 휴면아이디로 분류 시 개인정보는 “vchatcloud”에서 이용중인 개인정보와 별도 분리하여 보관합니다. 보관되는 정보는 보관 외 다른 목적으로 이용되지 않으며, 관련 업무 담당자만 열람할 수 있도록 접근을 제한합니다.

6. 이용자는 휴면아이디 보관기간 내에 로그인을 통해 휴면아이디 상태를 해제할 수 있습니다.

제15조 [계약 해지]

1. 이용자는 이용계약을 해지하고자 할 때 본인이 직접 “vchatcloud” 상담창구를 통하여 신청할 수 있으며 회사는 관련법 등이 정하는 바에 따라 이를 즉시 처리하여야 합니다.

2. 회사는 이용자가 다음 각 호에 해당할 경우에는 이용자의 동의 없이 이용계약을 해지할 수 있으며 그 사실을 이용자에게 통지합니다. 다만 회사가 긴급하게 해지할 필요가 있다고 인정하는 경우나 이용자의 귀책사유로 인하여 통지할 수 없는 경우에는 통지를 생략할 수 있습니다.

 - 이용자가 이 약관을 위반하고 일정 기간 이내에 위반 내용을 해소하지 않는 경우

 - 회사의 “vchatcloud” 제공목적 외의 용도로 서비스를 이용하거나 제3자에게 임의로 “vchatcloud” 서비스를 임대한 경우

 - 방송통신위원회ㆍ한국인터넷진흥원ㆍ과학기술정보통신부 등 관계기관이 스팸메시지ㆍ문자피싱메시지 등 불법행위의 전송사실을 확인하여 계약해지를 요청하는 경우

 - 제11조 [이용자의 의무] 규정을 위반한 경우

 - 제14조 [“vchatcloud” 이용의 제한 및 정지] 규정에 의하여 이용정지를 당한 이후 1년 이내에 이용정지 사유가 재발한 경우

 - 회사의 이용요금 등의 납입청구에 대하여 이용자가 이용요금을 체납할 경우

3. 회사는 휴면아이디가 휴면상태로 2년 이상 지속될 경우 본 계약을 해지할 수 있습니다.

단, 이용잔액의 상사소멸시효가 휴면상태로 2년이 지난 시점에 완성되는 경우 회사는 이용잔액의 상사소멸시효가 완성된 후에 계약을 해지할 수 있습니다.

4. 이용자 또는 회사가 계약을 해지할 경우 관련법 및 개인정보 처리방침에 따라 회사가 이용자정보를 보유하는 경우를 제외하고는 해지 즉시 이용자의 모든 데이터는 소멸됩니다.

제16조 [각종 자료의 저장기간]

회사는 “vchatcloud” 서비스 별로 이용자가 필요에 의해 저장하고 있는 자료에 대하여 일정한 저장기간을 정할 수 있으며 필요에 따라 그 기간을 변경할 수 있습니다.

제17조 [저작권 등 권한]

1. 이용자가 “vchatcloud” 서비스 페이지에 게시하거나 등록한 “데이터”의 지식재산권은 이용자에게 귀속됩니다. 단, 회사는 이용자의 “데이터”를 “vchatcloud” 서비스를 개선, 향상하고 새로운 서비스를 개발하기 위한 범위 내에서 활용할 수 있습니다.

2. vchatcloud의 디자인, 텍스트, 스크립트(script), 그래픽, 전송 기능 등 회사가 개발하여 제공하는 서비스에 관련된 모든 상표, 로고 등에 관한 저작권 등 지식재산권은 회사가 갖습니다.

3. 회사가 이용자에 대해 서비스를 제공하는 것은 이 약관에 정한 서비스 목적 하에서 회사가 허용한 방식으로 서비스에 대한 이용권한을 부여하는 것이며, 이용자는 서비스를 소유하거나 서비스에 관한 저작권을 보유하게 되는 것이 아닙니다.

4. 회사는 회사가 정한 이용조건에 따라 회원에게 계정 및 내용 등을 이용할 수 있는 이용권만을 부여하며, 이용자는 해당 권리를 제 3자에게 양도, 판매, 담보제공 등의 처분행위를 할 수 없습니다.

제18조 [서비스의 중단]

1. 회사는 컴퓨터 등 정보통신설비의 보수점검, 교체, 고장, 통신두절, 천재지변 등의 불가항력적인 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있으며 이 경우 사전공지를 합니다. 다만, 회사가 합리적으로 예측할 수 없는 사유로 인한 서비스 제공 중단의 경우에는 사후에 이를 공지할 수 있습니다. 상기 사유에 따른 서비스 중단과 관련하여 회사는 중대한 과실이 있지 않는 한, 이용자에 대한 손해배상책임을 지지 않습니다.

2. 회사는 사업적 판단에 따라 vchatcloud 서비스 중단을 결정할 수 있으며, 이에 따른 이용자의 서비스 이용에 따른 기대이익에 대한 손실을 보장하지 않습니다. 서비스의 일시 정지나 중단의 경우 회사는 이를 이용자에게 사전에 공지하여 이용자의 불이익을 최소화하기 위해 노력합니다.

3. 서비스에 등록된 회사의 정보에 대해서는 이용자가 스스로 백업하여 서비스 중단에 따른 삭제 시 피해가 없도록 해야 합니다. 단, 별도의 데이터 백업을 받는 계약을 체결한 경우에는 서비스 중단 이전에 회사로부터 최종 데이터 백업을 받을 수 있습니다.

제19조 [해외 이용]

1. 회사는 대한민국 내에 설치된 서버를 기반으로 서비스를 제공·관리하고 있습니다. 따라서 회사는 대한민국의 영토 이외의 지역의 이용자가 서비스를 이용하고자 하는 경우 서비스의 품질 또는 사용의 완전성을 보장하지 않습니다. 따라서 이용자는 대한민국의 영토 이외의 지역에서 서비스를 이용하고자 하는 경우 스스로의 판단과 책임에 따라서 이용 여부를 결정하여야 하고, 특히 서비스의 이용과정에서 현지 법령을 준수할 책임은 이용자에게 있습니다.

제20조 [요금 등의 계산]

1. 이용자는 “vchatcloud”의 유료서비스를 이용하기 위해서는 서비스 내에서 “톡캐시”를 충전하여야 합니다.

2. 회사가 제공하는 유료서비스 이용과 관련하여 이용자가 납부하여야 할 요금은 이용료 안내에 게재한 바에 따릅니다.

제21조 [불법 면탈 요금의 청구]

1. 이용자가 불법으로 이용요금 등을 면탈할 경우에는 면탈한 금액의 2배에 해당하는 금액을 청구합니다.

제22조 [요금 등의 이의신청]

1. 이용자는 청구된 요금 등에 대하여 이의가 있는 경우 청구일로부터 3개월 이내에 이의 신청을 할 수 있습니다.

2. 회사는 제1항의 이의 신청 접수 후 2주 이내에 해당 이의신청의 타당성 여부를 조사하여 그 결과를 이용자에게 통지합니다.

3. 부득이한 사유로 인하여 제2항에서 정한 기간 내에 이의신청결과를 통지할 수 없는 경우에는 그 사유와 재 지정된 처리기한을 명시하여 이용자에게 통지합니다.

제23조 [요금 등의 반환]

1. 회사는 요금 등의 과납 또는 오납이 있을 경우 이를 반환하거나 다음 요금에서 정산합니다.

제24조 [손해배상의 범위 및 청구]

1. 회사는 vchatcloud 서비스 제공과 관련하여 회사의 고의 또는 중대한 과실로 인해 이용자에게 손해가 발생한 경우, 본 이용약관 및 관계법령이 규정하는 범위 내에서 이용자에게 그 손해를 배상합니다.

① 손해배상으로 지불되는 금액의 총액은 어떠한 경우에도 이용자가 지불한 이용요금의 2배를 초과할 수 없습니다.

2. 회사는 그 손해가 천재지변 등 불가항력이거나 이용자의 고의 또는 과실로 인하여 발생된 때에는 손해배상을 하지 않습니다.

3. 손해배상의 청구는 회사에 청구사유, 청구금액 및 산출근거를 기재하여 전자우편, 전화 등으로 신청하여야 합니다.

4. 회사 및 타인에게 피해를 주어 피해자의 고발 또는 소송 제기로 인하여 손해배상이 청구된 이용자는 이에 응하여야 합니다.

제25조 [면책]

1. 회사는 다음 각 호의 경우로 “vchatcloud”을 제공할 수 없는 경우 이로 인하여 이용자에게 발생한 손해에 대해서는 책임을 부담하지 않습니다.

① 천재지변 또는 이에 준하는 불가항력의 상태가 있는 경우

 - “vchatcloud”의 효율적인 제공을 위한 시스템 개선, 장비 증설 등 계획된 “vchatcloud” 서비스 중지 일정을 사전에 공지한 경우

 - “vchatcloud” 제공을 위하여 회사와 “vchatcloud” 제휴계약을 체결한 제3자의 고의적인 방해가 있는 경우

 - 이용자의 귀책사유로 “vchatcloud” 이용에 장애가 있는 경우

 - 회사의 고의 과실이 없는 사유로 인한 경우

2. 회사는 이용자가 “vchatcloud”을 통해 얻은 정보 또는 자료 등으로 인해 발생한 손해와 “vchatcloud”을 이용하거나 이용할 것으로부터 발생하거나 기대하는 손익 등에 대하여 책임을 면합니다.

3. 회사는 이용자의 채팅 내용을 감시하지 않습니다. 이용자가 게시 또는 전송한 자료의 내용에 대한 모든 법적 책임은 각 이용자에게 있습니다.

4. 회사는 이용자 상호간 또는 이용자와 제3자 상호간에 “vchatcloud”을 매개로 하여 물품거래 등을 한 경우에는 책임을 면합니다.

5. 회사는 무료로 제공하는 “vchatcloud” 서비스에 대하여 회사의 귀책사유로 이용자에게 “vchatcloud” 서비스를 제공하지 못하는 경우 책임을 면합니다.

6. 이 약관의 적용은 이용계약을 체결한 이용자에 한하며 제3자로부터의 어떠한 배상, 소송 등에 대하여 회사는 책임을 면합니다.

7. 컴퓨터와 통신 시스템의 오류에 따라 vchatcloud 서비스의 일시 중지 또는 중단이 발생할 수 있으며, 회사는 이에 따른 서비스의 오류 없음이나 이용자가 등록한 계정의 손실이 발생하지 않음을 보장하지 않습니다.

8. 회사는 이용자가 다른 이용자가 게재한 정보, 자료, 사실의 정확성 등을 신뢰함으로써 입은 손해에 대하여 책임을 지지 않습니다.

제26조 [준거법 및 관할]

1. 회사와 이용자는 서비스와 관련하여 발생한 분쟁을 원만하게 해결하기 위하여 필요한 모든 노력을 하여야 합니다.

2. 만약 제1항의 분쟁이 원만하게 해결되지 못하여 소송이 제기된 경우, 소송은 관련 법령에 정한 절차에 따른 법원을 관할 법원으로 합니다.

3. 회사와 이용자간에 제기된 소송에는 대한민국 법을 적용합니다.

부칙

제1조 [시행일]

1. 이 약관은 2020년 1월 1일부터 적용 한다.""",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static Future<dynamic> chatLongPressDialog(
    BuildContext context,
    Channel? channel,
    ChatItem data,
  ) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final isText = data.mimeType == MimeType.text;
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
                bottom: 25,
              ),
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                maxHeight: isText ? 150 : 120,
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
                mainAxisAlignment: isText
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Anchor(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      Navigator.pop(context);
                      await sendWhisperDialog(context, channel, data);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                    ),
                  ),
                  if (isText)
                    Anchor(
                      onTap: () async {
                        Navigator.pop(context);
                        await hideMessageDialog(context, channel, data);
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "가리기",
                          style: TextStyle(
                            color: Color(0xff333333),
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  Anchor(
                    onTap: () async {
                      Navigator.pop(context);
                      await reportUserDialog(context, channel, data);
                    },
                    child: const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "신고하기",
                        style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> reportUserDialog(
    BuildContext context,
    Channel? channel,
    ChatItem data,
  ) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          void submit() async {
            await VChatCloudApi.reportUser(
              roomId: roomId,
              buserChatId: data.clientKey!,
              buserNick: data.nickName!,
              buserMsg: data.message,
            )
                .then((commonResult) => {
                      if (commonResult.resultCd == -1)
                        showToast("이미 신고된 대상입니다.")
                      else if (commonResult.resultCd == 1)
                        showToast("정상적으로 신고되었습니다.")
                      else
                        throw Error(),
                    })
                .then((_) => Navigator.pop(context))
                .then((value) =>
                    Provider.of<ChannelStore>(context, listen: false)
                        .banClientList
                        .add(data.clientKey!))
                .onError((error, stackTrace) =>
                    {showToast("신고 처리에서 오류가 발생하였습니다."), logger.w(error)});
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
                    const Text(
                      "해당 유저를 신고하시겠습니까?",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 18.0,
                      ),
                    ),
                    const Text(
                      "신고 후 검토까지는 최대 24시간이 소요됩니다. VChatCloud 운영정책에 따라 강퇴될 수 있음을 알립니다.",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 12.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                            "신고",
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
        });
  }

  static Future<dynamic> hideMessageDialog(
    BuildContext context,
    Channel? channel,
    ChatItem data,
  ) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          void submit() async {
            data.message = "삭제된 메시지입니다.";
            data.isDeleteChatting = true;

            Navigator.pop(context);
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
                    const Text(
                      "채팅 내용을 가리시겠습니까?",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 18.0,
                      ),
                    ),
                    const Text(
                      "해당 내용은 현재 기기에서만 가려집니다.",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 12.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                            "삭제",
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
        });
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
