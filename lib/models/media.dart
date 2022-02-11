import 'dart:async';
import 'dart:typed_data';

import 'package:multi_crop_picker/crop/crop.dart';
import 'package:photo_manager/photo_manager.dart';

class Media extends AssetEntity {
  Media(id, typeInt, width, height, this.thumbdata, {this.crop})
      : super(
          id: id,
          typeInt: typeInt,
          width: width,
          height: height,
        );

  Future<Uint8List?> thumbdata;
  Crop? crop;
  Completer? completer;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Media && other.id == id;
  }
}