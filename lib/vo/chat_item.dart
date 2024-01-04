import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatItem extends ChannelMessageModel {
  late MessageType? _messageType = super.messageType;

  @override
  MessageType? get messageType => _messageType;

  set messageType(MessageType? value) {
    _messageType = value;
  }

  late String? _clientKey = super.clientKey;

  @override
  String? get clientKey => _clientKey;

  set clientKey(String? value) {
    _clientKey = value;
  }

  /// 내가 발신한 채팅(clientKey가 동일한 경우)
  bool isMe = false;

  bool isDeleteChatting = false;

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

  ChatItem.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  ChatItem.fromChannelMessageModel(ChannelMessageModel model)
      : super.fromJson({
          "message": model.message,
          "nickName": model.nickName,
          "clientKey": model.clientKey,
          "roomId": model.roomId,
          "mimeType": model.mimeType?.type,
          "messageType": model.messageType,
          "userInfo": model.userInfo,
          "messageDt": model.messageDt,
        }) {
    clientKey = super.clientKey;
    messageType = super.messageType;
  }
}
