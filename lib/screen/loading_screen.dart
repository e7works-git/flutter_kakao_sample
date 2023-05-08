import 'package:flutter/material.dart';
import 'package:flutter_kakao/custom_handler.dart';
import 'package:flutter_kakao/screen/footer.dart';
import 'package:flutter_kakao/store/channel_store.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoadingScreen();
  }
}

class _LoadingScreen extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    VChatCloud.connect(CustomHandler()).then((channel) {
      Provider.of<ChannelStore>(context, listen: false).setChannel(channel);
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff2a61be),
              Color(0xff5d48c6),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/common/logo.png',
              width: 200,
            ),
            const Positioned(bottom: 0, child: FooterArea()),
          ],
        ),
      ),
    );
  }
}
