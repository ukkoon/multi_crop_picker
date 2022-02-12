## Features

select & crop single or multiple image from gallery.

<img src="https://github.com/ukkoon/multi_crop_picker/blob/master/image_1.png?raw=true" width="400"/>
<img src="https://github.com/ukkoon/multi_crop_picker/blob/master/image_2.png?raw=true" width="400"/>


## Getting started

you should handle photo permission before use package.

### Android

android/app/src/main/AndroidManifest.xml

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

ios/Info.plist:
```
<key>NSPhotoLibraryUsageDescription</key>
<string>photo permission required.</string>
```

## Usage

```dart
    List<Uint8List>? res = await MultiCropPicker.selectMedia(
        context,
        maxLength: 3,
        previewHeight: MediaQuery.of(context).size.width
        aspectRatio: 1);
```

## Additional information

At first, there were no plans to deploy, maybe so there are many shortcomings.
if anyone ever uses it, please give me feedback and ratings.
(crop featrue based on xclud/flutter_crop, gallery feture based on CaiJingLong/flutter_photo_manager)
