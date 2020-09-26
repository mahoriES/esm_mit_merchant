import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class EsVideoPickerWidget extends StatefulWidget {
  final Function(File) onUpdate;
  EsVideoPickerWidget(this.onUpdate);
  @override
  _EsVideoPickerWidgetState createState() => _EsVideoPickerWidgetState();
}

class _EsVideoPickerWidgetState extends State<EsVideoPickerWidget> {
  VideoPlayerController videoPlayerController;
  bool isLoading;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  pickVideo() async {
    setState(() {
      isLoading = true;
    });
    await videoPlayerController?.dispose();
    PickedFile pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      videoPlayerController = VideoPlayerController.file(videoFile)
        ..setLooping(true);
      videoPlayerController.initialize().then((value) {
        widget.onUpdate(videoFile);
        setState(() {});
      });
      videoPlayerController.play();
    } else {
      widget.onUpdate(null);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : InkWell(
            onTap: pickVideo,
            child: Container(
              height: 100.toHeight,
              width: 100.toWidth,
              color: Colors.grey[300],
              child: videoPlayerController?.value?.initialized ?? false
                  ? AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoPlayerController),
                    )
                  : Center(
                      child: Icon(
                        Icons.video_call,
                        size: 30.toFont,
                      ),
                    ),
            ),
          );
  }
}
