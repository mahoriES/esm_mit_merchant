import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideoPage extends StatefulWidget {
  static const String routeName = '/esPlayVideoPage';

  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  VideoPlayerController controller;

  @override
  void initState() {
    controller = new VideoPlayerController.network(
      'https://stream.mux.com/uZG02aAGD022ot25wLAXSO6WUr8RUcVJ8n.m3u8',
    )
      ..initialize().then((value) => setState(() {}))
      ..setLooping(true);
    controller.play();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Video'),
        centerTitle: false,
      ),
      body: (controller?.value?.initialized ?? false)
          ? Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      VideoPlayer(controller),
                      Center(
                        child: Icon(
                          Icons.play_arrow,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(),
    );
  }
}
