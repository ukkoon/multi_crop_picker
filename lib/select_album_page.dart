import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectAlbumPage extends StatelessWidget {
  const SelectAlbumPage(
      {required this.albums,
      required this.title,
      required this.backgroundColor,
      required this.textColor,
      Key? key})
      : super(key: key);

  final List<AssetPathEntity> albums;
  final String title;
  final Color backgroundColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              color: textColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            title: Text(
              title,
              style: const TextStyle(fontSize: 17),
            ),
            pinned: true,
          ),
          SliverFillRemaining(
              child: ListView.separated(
            padding: const EdgeInsets.all(15),
            shrinkWrap: true,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(albums[index]);
                  },
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder(
                            future: (() async {
                              List<AssetEntity> assets = await albums[index]
                                  .getAssetListRange(start: 0, end: 1);
                              Uint8List thumbnail =
                                  (await assets[0].thumbnailData)!;
                              return thumbnail;
                            })(),
                            builder: (context, snapshot) => snapshot.hasData
                                ? Image.memory(
                                    snapshot.data as Uint8List,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container()),
                        const SizedBox(
                          width: 15,
                        ),
                        IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                albums[index].name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                albums[index].assetCount.toString(),
                                style: TextStyle(
                                    color: textColor.withOpacity(0.7)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 30,
              );
            },
          )),
        ]),
      ),
    );
  }
}
