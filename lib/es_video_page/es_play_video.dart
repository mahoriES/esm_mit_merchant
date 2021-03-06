import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayVideoPageParam {
  String playUrl;
  String thumbnailUrl;
  PlayVideoPageParam(this.playUrl, this.thumbnailUrl);
}

class PlayVideoPage extends StatefulWidget {
  static const String routeName = '/esPlayVideoPage';

  final PlayVideoPageParam param;
  PlayVideoPage(this.param);

  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  void initState() {
    controller = new VideoPlayerController.network(
      widget.param?.playUrl ?? '',
    );

    chewieController = ChewieController(
      videoPlayerController: controller,
      looping: true,
      allowMuting: true,
    );

    if (!(widget.param?.playUrl == null ||
        (widget.param?.playUrl?.isEmpty ?? true))) {
      controller.initialize().then((value) => setState(() {}));
      controller.play();
    }

    super.initState();
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
                      imageUrl: widget.param?.thumbnailUrl ?? '',
                      errorWidget: (context, url, error) => Container(
                        width: SizeConfig().screenWidth,
                        height: 200.toHeight,
                        color: Colors.grey,
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
