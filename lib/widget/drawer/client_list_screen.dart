import 'package:flutter/material.dart';
import 'package:flutter_messenger/store/channel_store.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

final langList = {
  null: "사용 안함",
  "ko": '한국어',
  "de": 'Deutsch',
  "ru": 'русский',
  "vi": 'Tiếng Việt',
  "es": 'español',
  "ar": 'عربي',
  "en": 'English',
  "it": 'italiano',
  "ja": '日本語',
  'zh-CN': '简体中文',
  'zh-TW': '繁體中文',
  "id": 'bahasa Indonesia',
  "tl": 'Tagalog',
  "th": 'ไทย',
  "tr": 'Türk',
  "pt": 'português',
  "fr": 'français',
  "hi": 'हिन्दी',
  "gl": 'galego',
  "gu": 'ગુજરાતી',
  "el": 'Ελληνικά',
  "nl": 'Nederlands',
  "ne": 'नेपाली',
  "no": 'norsk',
  "da": 'dansk',
  "lo": 'ພາສາລາວ',
  "lv": 'latviski',
  "la": 'Latinus',
  "ro": 'Română',
  "lb": 'Lëtzebuergesch',
  "lt": 'lietuvių',
  "mr": 'मराठी',
  "mi": 'Maori',
  "mk": 'македонски',
  "mg": 'Malagasy',
  "ml": 'മലയാളം',
  "ms": 'Melayu',
  "mt": 'malti',
  "mn": 'Монгол',
  "hmn": 'Mongolian',
  "my": 'ဗမာ (ဗမာ)၊',
  "eu": 'euskara',
  "be": 'беларуская',
  "bn": 'বাংলা',
  "bs": 'bosanski',
  "bg": 'български',
  "sm": 'Samoa',
  "sr": 'Српски',
  "ceb": 'Cebuano',
  "st": 'Sesotho sa Borwa',
  "so": 'Soomaali',
  "sn": 'Shona',
  "su": 'basa Sunda',
  "sw": 'kiswahili',
  "sv": 'svenska',
  "gd": 'Gàidhlig na h-Alba',
  "sk": 'slovenský',
  "sl": 'Slovenščina',
  "sd": 'سنڊي',
  "si": 'ශ්‍රී ලාංකික (සිංහල)',
  "hy": 'հայերեն',
  "is": 'íslenskur',
  "ht": 'ayisyen',
  "ga": 'Gaeilge',
  "az": 'Azərbaycan',
  "af": 'Afrikaans',
  "sq": 'shqiptare',
  "am": 'አማርኛ',
  "et": 'eesti keel',
  "eo": 'Esperanto',
  "or": 'ଓଡିଆ',
  "yo": 'Yoruba',
  "ur": 'اردو',
  "uz": "o'zbek",
  "uk": 'український',
  "cy": 'Cymraeg',
  "ug": 'ئۇيغۇرچە',
  "ig": 'igbo',
  "yi": 'יידיש',
  "jw": 'basa jawa',
  "ka": 'ქართული',
  "zu": 'Zulu',
  "ny": 'nja language',
  "cs": 'čeština',
  "kk": 'қазақ',
  "ca": 'català',
  "kn": 'ಕನ್ನಡ',
  "co": 'Corsu',
  "xh": 'isiXhosa',
  "ku": 'Kurdî',
  "hr": 'Hrvatski',
  "km": 'ខ្មែរ',
  "rw": 'Kinyarwanda',
  "ky": 'Кыргызча',
  "ta": 'தமிழ்',
  "tg": 'тоҷикӣ',
  "tt": 'Татар',
  "te": 'తెలుగు',
  "tk": 'Türkmenler',
  "ps": 'پښتو',
  "pa": 'ਪੰਜਾਬੀ',
  "fa": 'فارسی',
  "pl": 'Polski',
  "fy": '프리지아어',
  "fi": 'Suomalainen',
  "haw": 'Ōlelo Hawaiʻi',
  "ha": 'Hausa',
  "hu": 'Magyar',
  "iw": 'עִברִית',
  "he": 'עִברִית',
  "zh": '简体中文',
}.entries.toList();

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
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
    var channel = Provider.of<ChannelStore>(context);
    var clientList = channel.clientList;
    var translateClientKeyMap = channel.translateClientKeyMap;

    return Scrollbar(
      controller: sc,
      child: ListView.separated(
        controller: sc,
        padding: const EdgeInsets.all(15),
        itemCount: clientList.length,
        itemBuilder: (context, index) {
          var user = clientList[index];

          var isMe = user.clientKey == channel.channel?.user?.clientKey;
          if (isMe) {
            return const SizedBox();
          }

          return SizedBox(
            height: 35,
            child: Anchor(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (translateClientKeyMap[user.clientKey] == null) {
                  await showLangList(context, user, channel);
                } else {
                  channel.removeTranslate(user.clientKey);
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(35 / 2),
                      ),
                      border:
                          Border.all(width: 2, color: const Color(0xffeaeaea)),
                      color: const Color(0xffeaeaea),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(35 / 2),
                      ),
                      child: Image.asset(
                        "assets/profile/profile_img_${user.userInfo?['profile'].toString() ?? '1'}.png",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              user.nickName,
                              style: const TextStyle(
                                color: Color(0xff333333),
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "번역",
                                style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 10.0,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  width: 16,
                                  height: 10,
                                  child: Transform.scale(
                                    scale: 0.5,
                                    child: Switch(
                                      inactiveTrackColor:
                                          const Color(0xffcccccc),
                                      inactiveThumbColor:
                                          const Color(0xff999999),
                                      activeTrackColor: const Color(0xffc9ddff),
                                      activeColor: const Color(0xff2a61be),
                                      value: translateClientKeyMap[
                                              user.clientKey] !=
                                          null,
                                      onChanged: (value) async {
                                        if (translateClientKeyMap[
                                                user.clientKey] ==
                                            null) {
                                          await showLangList(
                                              context, user, channel);
                                        } else {
                                          channel
                                              .removeTranslate(user.clientKey);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                langList
                                    .firstWhere(
                                      (element) =>
                                          element.key ==
                                          translateClientKeyMap[user.clientKey],
                                      orElse: () =>
                                          const MapEntry<String?, String>(
                                              null, "사용 안함"),
                                    )
                                    .value,
                                style: const TextStyle(
                                  color: Color(0xff000000),
                                  fontSize: 10.0,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          var isMe =
              clientList[index].clientKey == channel.channel?.user?.clientKey;

          return SizedBox(height: isMe ? 0 : 15);
        },
      ),
    );
  }

  Future<dynamic> showLangList(
    BuildContext context,
    UserModel user,
    ChannelStore channel,
  ) =>
      showDialog(
        context: context,
        builder: (context) {
          final controller = ScrollController();
          final maxHeight = MediaQuery.of(context).size.height * 0.6;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 280,
                maxHeight: (langList.length + 1) * 45 > maxHeight
                    ? maxHeight
                    : (langList.length + 1) * 45,
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xffcccccc)),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: const Text(
                      "번역 언어 선택 ",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: controller,
                      child: ListView.builder(
                        controller: controller,
                        itemCount: langList.length,
                        itemBuilder: (context, index) => SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: TextButton(
                            onPressed: () {
                              if (langList[index].key == null) {
                                channel.removeTranslate(user.clientKey);
                              } else {
                                channel.addTranslate(
                                    user.clientKey, langList[index].key!);
                              }

                              Navigator.of(context).pop();
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                langList[index].value,
                                style: const TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
