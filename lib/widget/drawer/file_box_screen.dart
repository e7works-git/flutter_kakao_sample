import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/main.dart';
import 'package:flutter_messenger/store/files_store.dart';
import 'package:flutter_messenger/util/util.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';
import 'package:flutter_messenger/widget/common/text_middle_ellipsis.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class FileBoxScreen extends StatefulWidget {
  const FileBoxScreen({super.key});

  @override
  State<FileBoxScreen> createState() => _FileBoxScreenState();
}

class _FileBoxScreenState extends State<FileBoxScreen> {
  late final FileStore files;
  List<int> clickedImageListIndex = [];
  List<int> clickedVideoListIndex = [];
  List<int> clickedFileListIndex = [];
  late final ScrollController _imageScroll;
  late final ScrollController _videoScroll;
  late final ScrollController _fileScroll;
  List<String> tabList = ['사진', '동영상', '파일'];

  @override
  void initState() {
    super.initState();
    files = Provider.of<FileStore>(context, listen: false);
    _imageScroll = ScrollController();
    _videoScroll = ScrollController();
    _fileScroll = ScrollController();
    init();
  }

  @override
  void dispose() {
    _imageScroll.dispose();
    _videoScroll.dispose();
    _fileScroll.dispose();
    super.dispose();
  }

  void init() async {
    List<FileModel> list = await VChatCloudApi.getFileList(roomId: roomId);
    files.init(list);
  }

  @override
  Widget build(BuildContext context) {
    var files = Provider.of<FileStore>(context);

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              height: 30,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xffdddddd),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: const Color(0xff333333),
                // indicatorPadding: const EdgeInsets.symmetric(horizontal: 25),
                tabs: tabList
                    .map(
                      (element) => Tab(
                        child: Text(
                          element,
                          style: const TextStyle(
                            color: Color(0xff333333),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  basedItem(files.imageList, clickedImageListIndex,
                      _imageScroll, "image", "사진이 없습니다."),
                  basedItem(files.videoList, clickedVideoListIndex,
                      _videoScroll, "video", "동영상이 없습니다."),
                  basedItem(files.fileList, clickedFileListIndex, _fileScroll,
                      "file", "파일이 없습니다."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makePictureItem(bool focused, FileModel data) {
    return GestureDetector(
      onDoubleTap: () => Navigator.pushNamed(
        context,
        '/preview_image',
        arguments: data,
      ),
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
          border: Border.all(
            width: focused ? 2 : 1,
            color: focused ? const Color(0xff2a61be) : const Color(0xffdddddd),
          ),
        ),
        padding: focused ? null : const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(3),
          ),
          child: FastCachedImage(
            url: '${ApiPath.loadFile}?fileKey=${data.fileKey}',
            fit: BoxFit.contain,
            fadeInDuration: const Duration(microseconds: 1),
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.close),
            loadingBuilder: (context, loadingProgress) => Center(
              child: CircularProgressIndicator(
                value: loadingProgress.progressPercentage.value,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget makeItem(bool focused, FileModel data, String type) {
    return Opacity(
      opacity: focused ? 1 : 0.7,
      child: Container(
        width: 270,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: focused ? const Color(0xff2a61be) : const Color(0xffdddddd),
            width: focused ? 2 : 1,
          ),
        ),
        padding: focused ? null : const EdgeInsets.all(1),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                type == "video"
                    ? Icons.play_circle_outline
                    : Icons.file_present,
                size: 25,
                color: const Color(0xff999999),
              ),
              const SizedBox(width: 10),
              basicFileItem(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget basicFileItem(FileModel data) {
    List<String> ymd = data.expire.split(".");
    String sizeText = Util.getSizedText(data.fileSize);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextMiddleEllipsis(
            data.originFileNm ?? data.fileNm,
            style: const TextStyle(
              color: Color(0xff333333),
              fontSize: 14.0,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "유효기간 : ${ymd[0]}-${ymd[1]}-${ymd[2]}까지",
            style: const TextStyle(
              color: Color(0xff666666),
              fontSize: 10.0,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            sizeText,
            style: const TextStyle(
              color: Color(0xff666666),
              fontSize: 10.0,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  Widget basedItem(List<FileModel> eachList, List<int> eachIndex,
      ScrollController sc, String type, String noItems) {
    return Column(
      children: [
        Expanded(
          child: (eachList.isNotEmpty)
              ? Scrollbar(
                  controller: sc,
                  child: type == "image"
                      ? GridView.count(
                          controller: _imageScroll,
                          padding: const EdgeInsets.all(15),
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          children: List.generate(
                            eachList.length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (eachIndex.contains(index)) {
                                    eachIndex.removeWhere(
                                        (element) => element == index);
                                  } else {
                                    eachIndex.add(index);
                                  }
                                  eachIndex.toSet().toList();
                                });
                              },
                              child: makePictureItem(
                                eachIndex.contains(index),
                                eachList[index],
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: sc,
                          padding: const EdgeInsets.all(15),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                if (eachIndex.contains(index)) {
                                  eachIndex.removeWhere(
                                      (element) => element == index);
                                } else {
                                  eachIndex.add(index);
                                }
                                eachIndex.toSet().toList();
                              });
                            },
                            child: makeItem(eachIndex.contains(index),
                                eachList[index], type),
                          ),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemCount: eachList.length,
                        ))
              : Container(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    noItems,
                  ),
                ),
        ),
        makeBottomBar(eachIndex, eachList)
      ],
    );
  }

  Widget makeBottomBar(List<int> indexList, List<FileModel> fileList) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xffdddddd),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Anchor(
              onTap: () {
                setState(() {
                  indexList.clear();
                });
              },
              child: Icon(
                Icons.check_circle,
                color: indexList.isEmpty
                    ? const Color(0xffcccccc)
                    : const Color(0xff2A61BE),
                size: 20,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "${indexList.length}개 선택",
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 14.0,
              ),
            ),
          ]),
          TextButton(
            onPressed: () async {
              if (indexList.isEmpty) {
                return Util.showToast("파일을 선택해주세요.");
              }
              download() async {
                await Future.wait(indexList.map(
                  (e) async => VChatCloudApi.download(
                    file: fileList[e],
                    downloadPath: await Util.getDownloadPath(),
                  ),
                ));
                Util.showToast("${indexList.length}개 파일이 저장되었습니다.");
                indexList.clear();
                setState(() {});
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
                color: Color(0xff333333),
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
