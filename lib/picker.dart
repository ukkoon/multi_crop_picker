import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:multi_crop_picker/crop/crop.dart';
import 'package:multi_crop_picker/select_album_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'models/album.dart';
import 'models/media.dart';

class MultiCropPicker {
  static Future<List<Uint8List>?> selectMedia(
    context, {
    String? titleText = '',
    String? completeText = 'done',
    String? selectAlbumText = '',
    int? crossAxisCount = 4,
    int? maxLength = 2,
    double? aspectRatio = 1.0 / 1.91,
    double? previewHeight = 300,
    double? previewShowingRatio = 1 / 3,
    Color? backgroundColor = Colors.grey,
    Color? tagColor = Colors.yellow,
    Color? tagTextColor = Colors.black,
    Color? textColor = Colors.white,
    Widget? loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    Widget? actionLoadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
  }) async {
    assert(maxLength! > 0);
    assert(crossAxisCount! > 0);
    assert(aspectRatio! > 0);
    assert(previewHeight! >= 0);
    assert(previewShowingRatio! >= 0);

    return await Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
            builder: (context) => _SelectMediaPage(
                  titleText!,
                  completeText!,
                  selectAlbumText!,
                  crossAxisCount!,
                  maxLength!,
                  aspectRatio!,
                  previewHeight!,
                  previewShowingRatio!,
                  backgroundColor!,
                  tagColor!,
                  tagTextColor!,
                  textColor!,
                  loadingWidget!,
                  actionLoadingWidget!,
                  key: UniqueKey(),
                )));
  }
}

class _SelectMediaPage extends StatefulWidget {
  const _SelectMediaPage(
      this.titleText,
      this.completeText,
      this.selectAlbumText,
      this.crossAxisCount,
      this.maxLength,
      this.aspectRatio,
      this.previewHeight,
      this.previewShowingRatio,
      this.backgroundColor,
      this.tagColor,
      this.tagTextColor,
      this.textColor,
      this.loadingWidget,
      this.actionLoadingWidget,
      {Key? key})
      : super(key: key);

  final String titleText, completeText, selectAlbumText;
  final int crossAxisCount, maxLength;
  final double aspectRatio, previewHeight, previewShowingRatio;

  final Color backgroundColor, tagColor, textColor, tagTextColor;
  final Widget loadingWidget, actionLoadingWidget;

  @override
  __SelectMediaPageState createState() => __SelectMediaPageState();
}

class __SelectMediaPageState extends State<_SelectMediaPage> {
  late ScrollController previewCtrl = ScrollController(initialScrollOffset: 0);
  late ScrollController gridCtrl = ScrollController(initialScrollOffset: 0);
  late List<AssetPathEntity> albums;
  late BuildContext providerCtx;
  late final Future<InitData> _data = fetchData();
  bool canLoad = true;
  bool isLoading = false;

  final animDuration = const Duration(milliseconds: 300);
  late double previewHideRatio = 1 - widget.previewShowingRatio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
                future: _data,
                builder: (context, snapshot) =>
                    snapshot.hasData && albums.isNotEmpty
                        ? ChangeNotifierProvider(
                            create: (context) => Album(
                                (snapshot.data as InitData).recentPhotos,
                                albums[0], []),
                            builder: (context, child) {
                              providerCtx = context;
                              return CustomScrollView(
                                controller: previewCtrl,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                    backgroundColor: widget.backgroundColor,
                                    foregroundColor: widget.textColor,
                                    elevation: 0,
                                    title: Text(
                                      widget.titleText,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    actions: [actionButton()],
                                    pinned: true,
                                    snap: true,
                                    floating: true,
                                  ),
                                  if (context.watch<Album>().inited)
                                    SliverAppBar(
                                      pinned: false,
                                      leading: Container(),
                                      snap: true,
                                      floating: true,
                                      backgroundColor: Colors.black,
                                      collapsedHeight: widget.previewHeight,
                                      flexibleSpace: preview(),
                                    ),
                                  SliverAppBar(
                                    backgroundColor: widget.backgroundColor,
                                    elevation: 0,
                                    title: header(),
                                    centerTitle: false,
                                    automaticallyImplyLeading: false,
                                    titleSpacing: 0,
                                    pinned: true,
                                  ),
                                  SliverFillRemaining(
                                    child: medias(),
                                  )
                                ],
                              );
                            },
                          )
                        : Center(
                            child: widget.loadingWidget,
                          )),
          ],
        ),
      ),
    );
  }

  Widget actionButton() {
    if (providerCtx
        .watch<Album>()
        .selectedMedias
        .every((e) => e.completer!.isCompleted || isLoading)) {
      return GestureDetector(
        onTap: () => tapComplete(),
        child: Container(
          padding: const EdgeInsets.only(right: 15),
          alignment: Alignment.center,
          child: Text(
            widget.completeText,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(right: 15),
      child: widget.actionLoadingWidget,
    );
  }

  Widget preview() {
    List<Media> mediasCopy =
        List.from(providerCtx.read<Album>().selectedMedias);
    Media? selectedMedia = providerCtx.watch<Album>().selectedMedia;
    mediasCopy.sort((a, b) => a == selectedMedia ? 1 : -1);
    if (providerCtx.watch<Album>().selectedMedias.isNotEmpty) {
      return Stack(
        children: [
          ...mediasCopy.map((e) => Opacity(
              key: Key(e.id),
              opacity: e == selectedMedia ? 1 : 0.001,
              child: e.crop!))
        ],
      );
    } else {
      return Container(
        color: Colors.black,
      );
    }
  }

  Widget header() {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(
            15,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                providerCtx.read<Album>().currentAlbum.name,
                style: TextStyle(color: widget.textColor, fontSize: 15),
              ),
              const SizedBox(
                width: 15,
              ),
              Transform.rotate(
                angle: pi / 2,
                child: Icon(
                  Icons.navigate_next,
                  size: 18,
                  color: widget.textColor,
                ),
              )
            ],
          ),
        ),
        onTap: () async {
          var result = await Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return SelectAlbumPage(
              albums: albums,
              title: widget.selectAlbumText,
              textColor: widget.textColor,
              backgroundColor: widget.backgroundColor,
            );
          }));

          switch (result.runtimeType) {
            case AssetPathEntity:
              var list = await (result as AssetPathEntity)
                  .getAssetListRange(start: 0, end: widget.crossAxisCount * 10);

              list = list
                  .map((e) => Media(
                        e.id,
                        e.typeInt,
                        e.width,
                        e.height,
                        e.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                      ))
                  .toList();

              setState(() {
                providerCtx.read<Album>().setCurrentAlbum(result);
                providerCtx.read<Album>().assets = list;
                canLoad = true;
              });
              return;
            default:
              return;
          }
        });
  }

  Widget medias() {
    List<Media> assets = providerCtx.watch<Album>().assets;

    return NotificationListener(
      child: GridView.builder(
          shrinkWrap: true,
          primary: false,
          controller: gridCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: assets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
          ),
          itemBuilder: (context, index) {
            return FutureBuilder(
                future: assets[index].thumbdata,
                builder: (context, snapshot) => snapshot.hasData
                    ? InkWell(
                        onTap: () => tapMedia(assets[index]),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.memory(
                                snapshot.data as Uint8List,
                                key: Key(assets[index].id),
                                fit: BoxFit.cover,
                              ),
                            ),
                            tag(assets[index])
                          ],
                        ),
                      )
                    : Container());
          }),
      onNotification: (t) {
        if (t is ScrollUpdateNotification) {
          if (t.metrics.extentAfter < 300 && canLoad) loadMedias();

          if (t.scrollDelta! > 20.0 && previewCtrl.offset == 0) {
            previewCtrl.animateTo(widget.previewHeight * previewHideRatio,
                duration: animDuration, curve: Curves.easeOut);
          } else if (t.scrollDelta! <= -20 && gridCtrl.offset <= 0) {
            previewCtrl.animateTo(0,
                duration: animDuration, curve: Curves.easeOut);
          } else if (t.scrollDelta! <= -20 && previewCtrl.offset == 0) {
            previewCtrl.animateTo(widget.previewHeight * previewHideRatio,
                duration: animDuration, curve: Curves.easeOut);
          }
        }
        return true;
      },
    );
  }

  Widget tag(Media media) {
    String text = "";
    Color color = Colors.transparent;
    Color backgroundColor = Colors.transparent;
    int idx =
        providerCtx.watch<Album>().selectedMedias.indexWhere((e) => e == media);

    if (idx != -1) {
      text = (idx + 1).toString();
      color = widget.tagColor;
    }

    if (idx != -1 && media == providerCtx.watch<Album>().selectedMedia) {
      backgroundColor = Colors.black38;
    }

    return Container(
      padding: const EdgeInsets.only(top: 5, right: 5),
      color: backgroundColor,
      alignment: Alignment.topRight,
      height: 100,
      width: 100,
      child: widget.maxLength == 1
          ? Container()
          : Wrap(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    widget.maxLength > 1 ? text : "",
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.tagTextColor,
                        fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                )
              ],
            ),
    );
  }

  scrolls(Media media) async {
    double itemheigth =
        MediaQuery.of(context).size.width / widget.crossAxisCount;
    int index = providerCtx.read<Album>().assets.indexOf(media);

    gridCtrl.animateTo(index ~/ widget.crossAxisCount * itemheigth,
        duration: animDuration, curve: Curves.easeOut);

    previewCtrl.animateTo(0, duration: animDuration, curve: Curves.easeOut);
  }

  loadMedias() async {
    canLoad = false;
    List<Media> assets = providerCtx.read<Album>().assets;

    var list = await providerCtx.read<Album>().currentAlbum.getAssetListRange(
        start: assets.length, end: assets.length + widget.crossAxisCount * 10);

    if (list.isNotEmpty) {
      list = list
          .map((e) => Media(
                e.id,
                e.typeInt,
                e.width,
                e.height,
                e.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              ))
          .toList();

      providerCtx.read<Album>().load(list);
      canLoad = true;
    }
  }

  Future<InitData> fetchData() async {
    // Map<AssetPathEntity, List<AssetEntity>> albumMap = {};

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();

    // for (int i = 0; i < albums.length; i++) {
    //   albumMap.addAll({albums[i]: await albums[i].getSubPathList()});
    // }

    // albums.sort((a, b) {
    //   if (a.isAll) {
    //     return -1;
    //   }
    //   return 1;
    // });

    List<AssetPathEntity> _onlyImageAlbums = [];

    for (int i = 0; i < albums.length; i++) {
      var list = await albums[i]
          .getAssetListRange(start: 0, end: widget.crossAxisCount * 10);

      if (list.isNotEmpty) _onlyImageAlbums.add(albums[i]);
    }

    this.albums = _onlyImageAlbums;

    var list = await albums[0]
        .getAssetListRange(start: 0, end: widget.crossAxisCount * 10);

    return InitData(
      recentPhotos: list
          .map(
            (e) => Media(
              e.id,
              e.typeInt,
              e.width,
              e.height,
              e.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
            ),
          )
          .toList(),
    );
  }

  tapMedia(Media media) async {
    if (!providerCtx.read<Album>().inited) {
      providerCtx.read<Album>().inited = true;
    }

    if (providerCtx.read<Album>().selectedMedias.contains(media)) {
      Media selectedMedia = providerCtx.read<Album>().selectedMedia!;
      if (selectedMedia == media) {
        providerCtx.read<Album>().deleteSelectedMedia(media);
      } else {
        providerCtx.read<Album>().setCurrentMedia(media);
        scrolls(media);
      }
    } else {
      if (widget.maxLength > 1 &&
          providerCtx.read<Album>().selectedMedias.length >= widget.maxLength) {
        return;
      }

      if (widget.maxLength == 1) {
        Media? selectedMedia = providerCtx.read<Album>().selectedMedia;
        if (selectedMedia != null) {
          providerCtx.read<Album>().deleteSelectedMedia(selectedMedia);
        }
      }

      Completer completer = Completer();

      media
          .thumbnailDataWithSize(const ThumbnailSize(4096, 4096))
          .then((value) {
        completer.complete(value);
        providerCtx.read<Album>().notifyListeners();
      });

      Uint8List thumbdata = (await media.thumbdata)!;

      Widget image = Stack(
        children: [
          Image.memory(
            thumbdata,
            fit: BoxFit.cover,
          ),
          FutureBuilder(
              future: completer.future,
              builder: (context, snapshot) => snapshot.hasData
                  ? Image.memory(
                      snapshot.data as Uint8List,
                      fit: BoxFit.cover,
                    )
                  : Container())
        ],
      );

      media.completer = completer;

      media.crop = Crop(
        controller: CropController(aspectRatio: widget.aspectRatio),
        child: image,
        dimColor: Colors.black,
        onChanged: (e) {
          if (previewCtrl.offset != 0) {
            previewCtrl.animateTo(0,
                duration: animDuration, curve: Curves.easeOut);
          }
        },
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
        overlay: FittedBox(
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1 / widget.aspectRatio,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1)),
          ),
        ),
      );

      providerCtx.read<Album>().addSelectedMedia(media);
      scrolls(media);
    }
  }

  void tapComplete() async {
    setState(() {
      isLoading = true;
    });

    try {
      var devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      List<Media> medias = providerCtx.read<Album>().selectedMedias;
      List<Uint8List> images = [];
      for (int i = 0; i < medias.length; i++) {
        var img =
            await medias[i].crop!.controller.crop(pixelRatio: devicePixelRatio);
        var byteData = await img?.toByteData(format: ui.ImageByteFormat.png);
        var buffer = byteData!.buffer.asUint8List();

        images.add(buffer);
      }
      Navigator.of(context).pop(images);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class InitData {
  final List<Media> recentPhotos;
  InitData({required this.recentPhotos});
}
