import 'package:flutter/material.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/widget/chat/video_player_screen.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final VideoPlayerData data;
  const VideoScreen({super.key, required this.data});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final VideoPlayer child;
  late final VideoPlayerController _controller;
  bool isClicked = true;
  bool get visibleButton => !_controller.value.isPlaying;

  late final Function() listener;

  @override
  void initState() {
    super.initState();
    child = widget.data.child;
    _controller = widget.data.child.controller;
    listener = () => setState(() {});
    _controller.addListener(listener);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void tapHandler() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Hero(
                      tag: "${widget.data.file.fileKey}_videoPlayerHero",
                      child: child,
                    ),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                    Positioned(
                      child: GestureDetector(
                        onTap: tapHandler,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                          width: double.infinity,
                          height: double.infinity,
                          color: visibleButton
                              ? Colors.black.withOpacity(0.6)
                              : Colors.transparent,
                          child: visibleButton
                              ? const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isClicked) ...[
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  padding: const EdgeInsets.only(right: 15),
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Anchor(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Image.asset(
                                'assets/common/exit_left.png',
                              ),
                            ),
                            // Container(
                            //   margin:
                            //       const EdgeInsets.only(left: 11, right: 13),
                            //   alignment: Alignment.centerLeft,
                            //   child: Text(widget.data.originFileNm.toString(),
                            //       style: const TextStyle(
                            //           color: Color(0xffffffff),
                            //           fontSize: 16.0),
                            //       textAlign: TextAlign.left),
                            // ),
                          ],
                        ),
                      ),
                      Anchor(
                        onTap: () async {
                          download() async {
                            Util.showToast("저장중입니다.");
                            await VChatCloudApi.download(
                                file: widget.data.file,
                                downloadPath: await Util.getDownloadPath());
                            Util.showToast("파일이 저장되었습니다.");
                          }

                          if (await Util.filePermissionCheck()) {
                            download();
                          } else {
                            var granted = await Util.requestFileWrite();
                            if (granted) download();
                          }
                        },
                        child: const Text(
                          "저장",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
