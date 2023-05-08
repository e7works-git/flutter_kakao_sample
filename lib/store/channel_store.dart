import 'package:flutter/material.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChannelStore extends ChangeNotifier {
  Channel? channel;
  List<ChatItem> chatLog = [];
  List<UserModel> clientList = [];
  Map<String, String> translateClientKeyMap = {};

  void setChannel(Channel channel) {
    this.channel = channel;
    notifyListeners();
  }

  void setChatLog(List<ChatItem> chatLog) {
    this.chatLog = chatLog;
    for (var i = 0; i < this.chatLog.length; i++) {
      if (i != 0) {
        this.chatLog[i - 1].nextClientKey = this.chatLog[i].clientKey;
        this.chatLog[i - 1].nextDt = this.chatLog[i].messageDt;
        this.chatLog[i]
          ..previousClientKey = this.chatLog[i - 1].clientKey
          ..previousDt = this.chatLog[i - 1].messageDt;
      }
      this.chatLog[i].isMe =
          this.chatLog[i].clientKey == channel?.user?.clientKey;
    }
    notifyListeners();
  }

  void addChatLog(ChatItem data) {
    if (chatLog.isNotEmpty) {
      chatLog.last.nextClientKey = data.clientKey;
      chatLog.last.nextDt = data.messageDt;
      data.previousClientKey = chatLog.last.clientKey;
      data.previousDt = chatLog.last.messageDt;
    }
    chatLog.add(data..isMe = data.clientKey == channel?.user?.clientKey);
    notifyListeners();
  }

  void setClientList(List<UserModel> clientList) {
    this.clientList = clientList;
    notifyListeners();
  }

  void addClientList(UserModel data) {
    clientList.add(data);
    notifyListeners();
  }

  void addTranslate(String clientKey, String translateLanguage) {
    translateClientKeyMap[clientKey] = translateLanguage;
    notifyListeners();
  }

  void removeTranslate(String clientKey) {
    translateClientKeyMap.remove(clientKey);
    notifyListeners();
  }

  void reset() {
    chatLog.clear();
    clientList.clear();
    translateClientKeyMap = {};
    notifyListeners();
  }
}
