import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao/main.dart';
import 'package:flutter_kakao/util/util.dart';
import 'package:flutter_kakao/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class PreviewImageScreen extends StatefulWidget {
  final FileModel data;
  const PreviewImageScreen({super.key, required this.data});

  @override
  State<PreviewImageScreen> createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen>
    with SingleTickerProviderStateMixin {
  bool isClicked = true;
  Size? imageSize;
  late final FastCachedImageProvider _imageProvider;
  late AnimationController _animationController;
  late Animation<Matrix4> _animation;
  final _transformationController = TransformationController();
  // TapDownDetails _doubleTapDetails = TapDownDetails();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });

    _imageProvider = FastCachedImageProvider(
        '${ApiPath.loadFile}?fileKey=${widget.data.fileKey}');
    var stream = _imageProvider.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      imageSize =
          Size(info.image.width.toDouble(), info.image.height.toDouble());
    }));
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // void _handleDoubleTapDown(TapDownDetails details) {
  //   _doubleTapDetails = details;
  // }

  void _handleDoubleTap() async {
    Matrix4 endMatrix;
    // Offset position = _doubleTapDetails.localPosition;
    var screenRatio = MediaQuery.of(context).size.aspectRatio;
    var imageRatio = imageSize?.aspectRatio;
    double ratio = imageSize != null
        ? screenRatio > imageRatio!
            ? imageRatio / screenRatio
            : screenRatio / imageRatio
        : 2;
    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      var fittedPosition = Size(
        -((1 / ratio) - 1) * MediaQuery.of(context).size.width / 2,
        -((1 / ratio) - 1) * MediaQuery.of(context).size.height / 2,
      );
      endMatrix = Matrix4.identity()
        ..translate(fittedPosition.width, fittedPosition.height)
        ..scale((1 / ratio));
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            isClicked = !isClicked;
          });
        },
        onDoubleTap: _handleDoubleTap,
        // onDoubleTapDown: _handleDoubleTapDown,
        child: Material(
          color: const Color(0x00000000),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: InteractiveViewer(
                  maxScale: 10,
                  transformationController: _transformationController,
                  child: FastCachedImage(
                    url: '${ApiPath.loadFile}?fileKey=${widget.data.fileKey}',
                    fit: BoxFit.contain,
                    fadeInDuration: const Duration(milliseconds: 1),
                    errorBuilder: (context, error, stackTrace) => const Text(
                      "이미지 파일을 불러올 수 없습니다.",
                      style: TextStyle(color: Colors.white),
                    ),
                    loadingBuilder: (context, loadingProgress) => Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.progressPercentage.value,
                      ),
                    ),
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
                                  roomId: roomId,
                                  file: widget.data,
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
              ]
            ],
          ),
        ),
      ),
    );
  }
}
