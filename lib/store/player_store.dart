import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ControllerInfo {
  VideoPlayerController controller;
  VisibilityInfo info;

  ControllerInfo(this.controller, this.info);
}

class PlayerStore with ChangeNotifier {
  final Map<String, ControllerInfo> map = {};

  setVideo(String fileKey, ControllerInfo video) {
    map[fileKey] = video;
    check();
  }

  check() {
    ControllerInfo? target;

    map.forEach((key, value) {
      if (value.info.visibleFraction == 1) {
        if (target == null) {
          target = value;
        } else if (target!.info.visibleBounds.bottom >
            value.info.visibleBounds.bottom) {
          if (target!.controller.value.isInitialized) {
            target!.controller.pause();
          }
          target = value;
        } else if (value.controller.value.isInitialized) {
          value.controller.pause();
        }
      } else {
        if (value.controller.value.isInitialized) {
          value.controller.pause();
        }
      }
    });

    if (target != null && target!.controller.value.isInitialized) {
      var notEnd = target!.controller.value.duration.inMilliseconds !=
          target!.controller.value.position.inMilliseconds;
      if (notEnd) {
        target!.controller.setVolume(0);
        target!.controller.play();
      }
    }
  }
}
