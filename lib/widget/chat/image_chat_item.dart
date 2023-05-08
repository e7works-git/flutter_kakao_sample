import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao/vo/chat_item.dart';
import 'package:flutter_kakao/widget/chat/chat_base_item.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ImageChatItem extends StatelessWidget {
  final ChatItem data;
  final FileModel file;
  const ImageChatItem(
    this.data, {
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBaseItem(
      data,
      GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/preview_image',
          arguments: file,
        ),
        child: Container(
          margin: data.isMe
              ? const EdgeInsets.only(right: 10)
              : const EdgeInsets.only(left: 8),
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 150,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: data.mimeType != MimeType.emojiImg
              ? FastCachedImage(
                  url: ApiPath.loadFile
                      .addGetParam({"fileKey": file.fileKey}).toString(),
                  fit: BoxFit.contain,
                  fadeInDuration: const Duration(microseconds: 1),
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "이미지 파일을 불러올 수 없습니다.",
                    style: TextStyle(color: Colors.white),
                  ),
                  loadingBuilder: (context, loadingProgress) => Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.progressPercentage.value,
                    ),
                  ),
                )
              : Image.asset(
                  "assets/${data.message}",
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
