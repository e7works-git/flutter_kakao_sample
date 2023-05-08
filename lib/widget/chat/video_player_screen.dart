import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao/store/player_store.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class VideoPlayerScreen extends StatefulWidget {
  final FileModel file;
  const VideoPlayerScreen({
    super.key,
    required this.file,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late final PlayerStore store;
  bool loading = true;
  bool mobileNetwork = true;
  bool visibleButton = true;

  @override
  void initState() {
    super.initState();
    store = Provider.of<PlayerStore>(context, listen: false);
    controllerInit();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void controllerInit() async {
    _controller = VideoPlayerController.network(ApiPath.loadFile
        .addGetParam({"fileKey": widget.file.fileKey}).toString());
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi) {
      await _controller.initialize();
      _controller.setVolume(0);
      _controller.pause();
      setState(() {
        loading = false;
        visibleButton = false;
      });
      // TODO: 영상 재생이 끝난 후 다시 visibleButton = true로 바꿔줘야 함
    } else {
      mobileNetwork = true;
      loading = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var videoPlayer = VideoPlayer(_controller);
    return mobileNetwork && !_controller.value.isInitialized
        ? Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
            ),
            child: Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        var flag = await downloadPopup();
                        if (flag) {
                          setState(() {
                            loading = true;
                          });
                          _controller.initialize().then((value) {
                            setState(() {
                              loading = false;
                              _controller.play();
                            });
                          });
                        }
                      },
                    ),
            ),
          )
        : VisibilityDetector(
            key: Key(widget.file.fileKey),
            onVisibilityChanged: (info) {
              if (context.mounted &&
                  ModalRoute.of(context)?.isCurrent == true) {
                store.setVideo(
                    widget.file.fileKey, ControllerInfo(_controller, info));
              }
            },
            child: VideoPlayerWidget(
              file: widget.file,
              controller: _controller,
              player: videoPlayer,
            ),
          );
  }

  Future<bool> downloadPopup() async {
    bool flag = false;
    await showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.only(
              top: 25,
              left: 25,
              right: 25,
              bottom: 15,
            ),
            constraints: const BoxConstraints(
              maxWidth: 280,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "다운로드 안내",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "영상 재생을 위해 다운로드를 진행합니다. 모바일 데이터일 경우 데이터 요금이 부과될 수 있습니다.\n다운로드 하시겠습니까?",
                      style: TextStyle(height: 1.2),
                    ),
                  ],
                ),
                SizedBox(
                  child: Row(
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
                        onPressed: () {
                          flag = true;
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "확인",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    return flag;
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final FileModel file;
  final VideoPlayerController controller;
  final VideoPlayer player;
  const VideoPlayerWidget({
    super.key,
    required this.file,
    required this.controller,
    required this.player,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool get visibleButton => !widget.controller.value.isPlaying;
  late final VideoPlayerController controller;
  late final PlayerStore store;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    store = Provider.of<PlayerStore>(context, listen: false);
    var flag = false;
    controller.addListener(() {
      if (flag != controller.value.isPlaying) {
        if (context.mounted) {
          setState(() {
            flag = controller.value.isPlaying;
          });
        }
      }
    });
  }

  void tapHandler() {
    if (controller.value.isPlaying) {
      fullscreenHandler();
    } else {
      if (controller.value.position.inMilliseconds ==
          controller.value.duration.inMilliseconds) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
    }
  }

  void fullscreenHandler() {
    if (controller.value.isPlaying) {
      controller.setVolume(1);
      Navigator.of(context)
          .pushNamed(
        "/video_player",
        arguments: VideoPlayerData(
          child: widget.player,
          file: widget.file,
        ),
      )
          .then((value) {
        controller.pause();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Hero(
              tag: "${widget.file.fileKey}_videoPlayerHero",
              child: widget.player,
            ),
            VideoProgressIndicator(controller, allowScrubbing: true),
            Positioned(
              child: GestureDetector(
                onTap: tapHandler,
                onLongPress: fullscreenHandler,
                onDoubleTap: fullscreenHandler,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  width: double.infinity,
                  height: double.infinity,
                  color: visibleButton
                      ? Colors.black.withOpacity(0.6)
                      : Colors.transparent,
                  child: visibleButton
                      ? const Icon(
                          Icons.play_circle_outline,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerData {
  final VideoPlayer child;
  final FileModel file;

  VideoPlayerData({
    required this.child,
    required this.file,
  });
}
