import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayVideoPage extends StatefulWidget {
  static const String routeName = '/esPlayVideoPage';

  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  void initState() {
    controller = new VideoPlayerController.network(
      'https://stream.mux.com/uZG02aAGD022ot25wLAXSO6WUr8RUcVJ8n.m3u8',
    );

    chewieController = ChewieController(
      videoPlayerController: controller,
      fullScreenByDefault: true,
      looping: true,
      allowMuting: true,
    );

    controller.initialize().then((value) => setState(() {}));
    controller.play();

    super.initState();
  }

  @override
  void deactivate() {
    controller?.pause();
    chewieController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: (controller?.value?.initialized ?? false)
          ? Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Chewie(
                  controller: chewieController,
                ),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.8,
                    child: CachedNetworkImage(
                      imageUrl: "http://via.placeholder.com/350x150",
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                      ),
                      fit: BoxFit.cover,
                      width: SizeConfig().screenWidth,
                    ),
                  ),
                ),
                Center(child: CircularProgressIndicator())
              ],
            ),
    );
  }
}
