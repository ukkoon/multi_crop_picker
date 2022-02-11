import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'media.dart';

class Album extends ChangeNotifier {
  Album(this._assets, this._currentAlbum, this._selectedMedias);

  Media? _selectedMedia;
  AssetPathEntity _currentAlbum;

  bool _inited = false;
  List<Media> _selectedMedias;
  List<Media> _assets;

  List<Media> get selectedMedias => _selectedMedias;

  bool get inited => _inited;
  set inited(value) => _inited = value;

  AssetPathEntity get currentAlbum => _currentAlbum;
  setCurrentAlbum(currentAlbum, {withNotify = true}) {
    if (withNotify) notifyListeners();
    _currentAlbum = currentAlbum;
  }

  deleteSelectedMedia(Media media) {
    _selectedMedias.remove(media);

    if (_selectedMedias.isNotEmpty) {
      _selectedMedia = _selectedMedias.last;
    } else {
      _selectedMedia = null;
    }
    notifyListeners();
  }

  setCurrentMedia(Media media) {
    _selectedMedia = media;
    notifyListeners();
  }

  Media? get selectedMedia => _selectedMedia;

  addSelectedMedia(Media media) {
    _selectedMedias.add(media);
    _selectedMedia = media;
    notifyListeners();
  }

  List<Media> get assets => _assets;

  set assets(assets) => _assets = assets;

  load(assets) {
    _assets.addAll(assets);
    notifyListeners();
  }
}