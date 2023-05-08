import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatItem {
  dynamic message;

  /// 닉네임
  String? nickName;
  final String? clientKey;
  final String? roomId;

  /// `MimeType`
  final MimeType? mimeType;

  /// `MessageType`
  final MessageType? messageType;

  /// YYYYMMDDHH24MISS 포맷
  late final DateTime messageDt;

  /// 사용자 정보(json)
  final dynamic userInfo;

  /// 내가 발신한 채팅(clientKey가 동일한 경우)
  bool isMe = false;

  /// 번역된 채팅 여부
  bool translated = false;

  String? previousClientKey;
  String? nextClientKey;
  DateTime? previousDt;
  DateTime? nextDt;

  /// 상대방 프로필 나오는 조건
  /// - 내 채팅 아닐 때
  ///   - 이번 채팅과 이전 채팅의 client key가 다를 때
  ///   - 이번 채팅과 이전 채팅의 시간이 다를 때
  /// - 내 채팅 아닐 때
  ///   - 귓속말일 때
  get profileNameCondition =>
      !isMe &&
          (previousClientKey != clientKey ||
              (previousDt != null && previousDt?.minute != messageDt.minute)) ||
      !isMe && messageType == MessageType.whisper;

  /// 내 프로필 나오는 조건
  /// - 내 채팅일 때
  ///   - 이번 채팅과 이전 채팅의 client key가 다를 때
  ///   - 이번 채팅과 이전 채팅의 시간이 다를 때
  /// - 내 채팅일 때
  ///   - 귓속말일 때
  get myProfileNameCondition =>
      isMe &&
          (previousClientKey != clientKey ||
              (previousDt != null && previousDt?.minute != messageDt.minute)) ||
      isMe && messageType == MessageType.whisper;

  /// 시간 나오는 조건
  /// - 다음 채팅이 같은 사람이 아닐 때
  /// - 다음 채팅의 시간이 같지 않을 때
  get timeCondition =>
      nextClientKey != clientKey ||
      (nextDt != null && nextDt?.minute != messageDt.minute);

  ChatItem.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        nickName = json['nickName'],
        clientKey = json['clientKey'],
        roomId = json['roomId'],
        mimeType = MimeType.getByCode(json['mimeType']),
        messageType = json['messageType'] is MessageType
            ? json['messageType']
            : MessageType.getByCode(json['messageType']),
        userInfo = json['userInfo'] is String
            ? jsonDecode(json['userInfo'])
            : json['userInfo'] {
    if (json['messageDt'] != null) {
      var date = json['messageDt'] as String?;
      if (date != null) {
        messageDt = DateTime(
          int.parse(date.substring(0, 4)),
          int.parse(date.substring(4, 6)),
          int.parse(date.substring(6, 8)),
          int.parse(date.substring(8, 10)),
          int.parse(date.substring(10, 12)),
          int.parse(date.substring(12, 14)),
        );
      }
    } else if (json['date'] != null) {
      var date = json['date'] as String?;
      if (date != null) {
        messageDt = DateFormat("yyyy-MM-dd hh:mm:ss").parse(date);
      }
    } else {
      messageDt = DateTime.now();
    }
  }
}
