import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:multi_crop_picker/multi_crop_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Uint8List>? photos;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () async {
                  photos = await MultiCropPicker.selectMedia(context,
                      maxLength: 2,
                      aspectRatio: 1.0,                      
                      previewShowingRatio: 1.0,
                      textColor: Colors.white,
                      backgroundColor: Colors.brown,
                      tagColor: Colors.yellow,
                      loadingWidget: const LoadingCircle(),
                      tagTextColor: Colors.black);
                  setState(() {});
                },
                child: const Text('get images')),
            if (photos != null)
              Expanded(child: ListView.builder(
                  itemCount: photos!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      child: Image.memory(photos![index]),
                    );
                  }))
          ],
        ),
      ),
    );
  }
}

class LoadingCircle extends StatelessWidget {
  const LoadingCircle(
      {Key? key,
      this.size = 22.0,
      this.backgroudColor = 0x000000,
      this.color = 0xFFFFFDE7})
      : super(key: key);
  final double size;
  final int backgroudColor;
  final int color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        backgroundColor: Color(backgroudColor),
        color: Color(color),
      ),
    );
  }
}
