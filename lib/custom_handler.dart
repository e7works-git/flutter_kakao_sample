import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:flutter_kakao/store/emoji_store.dart';
import 'package:flutter_kakao/store/files_store.dart';
import 'package:flutter_kakao/store/user_store.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class CustomHandler extends ChannelHandler {
  late final ChannelStore _channel;
  CustomHandler() {
    _channel = Provider.of<ChannelStore>(contextProvider.currentContext!,
        listen: false);
    reset();
  }

  void reset() {
    var channel = Provider.of<ChannelStore>(contextProvider.currentContext!,
        listen: false);
    if (channel.channel != null) {
      channel.reset();
      Provider.of<EmojiStore>(contextProvider.currentContext!, listen: false)
          .reset();
      Provider.of<FileStore>(contextProvider.currentContext!, listen: false)
          .reset();
      Provider.of<UserStore>(contextProvider.currentContext!, listen: false)
          .reset();
    }
  }

  @override
  void onCustom(ChannelResultModel message) {}

  @override
  void onJoinUser(ChannelResultModel message) async {
    Map<String, dynamic> data = message.body;
    var chatData = ChatItem.fromJson(
      data
        ..['messageType'] = MessageType.join
        ..['clientKey'] = '',
    );
    _channel.addChatLog(chatData);

    if (_channel.channel != null) {
      _channel.setClientList(await _channel.channel!.requestClientList());
    }
  }

  @override
  void onLeaveUser(ChannelResultModel message) {
    Map<String, dynamic> data = message.body;
    var chatData = ChatItem.fromJson(
      data
        ..['messageType'] = MessageType.leave
        ..['clientKey'] = '',
    );
    _channel.addChatLog(chatData);
  }

  @override
  void onMessage(ChannelResultModel message) {
    Map<String, dynamic> data = message.body;
    var chatData = ChatItem.fromJson(data);
    // 번역 사용 시
    if (chatData.mimeType == MimeType.text &&
        _channel.translateClientKeyMap[chatData.clientKey] != null) {
      VChatCloudApi.googleTranslation(
        text: chatData.message,
        target: _channel.translateClientKeyMap[chatData.clientKey]!,
        roomId: _channel.channel?.roomId,
      ).then((value) {
        _channel.addChatLog(chatData
          ..message = value.data
          ..translated = true);
      });
    } else {
      _channel.addChatLog(chatData);
    }
  }

  @override
  void onNotice(ChannelResultModel message) {
    Map<String, dynamic> data = message.body;
    var chatData =
        ChatItem.fromJson(data..['messageType'] = MessageType.notice);
    _channel.addChatLog(chatData);
  }

  @override
  void onWhisper(ChannelResultModel message) {
    Map<String, dynamic> data = message.body;
    var chatData =
        ChatItem.fromJson(data..['messageType'] = MessageType.whisper);
    _channel.addChatLog(chatData);
  }
}
