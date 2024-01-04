import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_messenger/screen/chat_screen.dart';
import 'package:flutter_messenger/screen/loading_screen.dart';
import 'package:flutter_messenger/screen/login_screen.dart';
import 'package:flutter_messenger/screen/preview_image_screen.dart';
import 'package:flutter_messenger/screen/video_screen.dart';
import 'package:flutter_messenger/store/channel_store.dart';
import 'package:flutter_messenger/store/emoji_store.dart';
import 'package:flutter_messenger/store/files_store.dart';
import 'package:flutter_messenger/store/player_store.dart';
import 'package:flutter_messenger/store/user_store.dart';
import 'package:flutter_messenger/util/util.dart';
import 'package:flutter_messenger/widget/chat/video_player_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';
import 'package:video_player_win/video_player_win.dart';

final GlobalKey<NavigatorState> contextProvider = GlobalKey<NavigatorState>();
final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();
final GlobalKey rowKey = GlobalKey();

const roomId = "YOUR_CHANNEL_KEY";

class VchatcloudApp extends StatelessWidget {
  const VchatcloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserStore()),
        ChangeNotifierProvider(create: (context) => ChannelStore()),
        ChangeNotifierProvider(create: (context) => EmojiStore()),
        ChangeNotifierProvider(create: (context) => FileStore()),
        ChangeNotifierProvider(create: (context) => PlayerStore()),
      ],
      child: MaterialApp(
        locale: const Locale('ko', 'KR'),
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) {
          if (locale == null) {
            Intl.defaultLocale = supportedLocales.first.toLanguageTag();
            return supportedLocales.first;
          }

          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              Intl.defaultLocale = supportedLocale.toLanguageTag();
              return supportedLocale;
            }
          }

          Intl.defaultLocale = supportedLocales.first.toLanguageTag();
          return supportedLocales.first;
        },
        builder: FToastBuilder(),
        navigatorKey: contextProvider,
        debugShowCheckedModeBanner: false,
        title: 'VChatCloud Demo',
        initialRoute: '/',
        theme: ThemeData(
          fontFamily: "Pretendard",
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.5,
                vertical: 10,
              ),
              minimumSize: const Size(10, 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        routes: {
          '/': (context) => const LoadingScreen(),
          '/login': (context) => const LoginScreen(),
          '/chat_screen': (context) => ChatScreen(
                key: chatScreenKey,
              ),
          '/preview_image': (context) => PreviewImageScreen(
              data: ModalRoute.of(context)!.settings.arguments as FileModel),
          '/video_player': (context) => VideoScreen(
                data: ModalRoute.of(context)!.settings.arguments
                    as VideoPlayerData,
              )
        },
      ),
    );
  }
}

void main() {
  if (!Util.isWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }
  FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 8));

  runApp(const VchatcloudApp());
}
