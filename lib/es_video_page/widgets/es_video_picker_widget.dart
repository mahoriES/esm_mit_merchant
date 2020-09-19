import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class EsVideoPickerWidget extends StatefulWidget {
  VideoPlayerController videoPlayerController;
  Function(VideoPlayerController) onUpdate;
  EsVideoPickerWidget(this.videoPlayerController, this.onUpdate);
  @override
  _EsVideoPickerWidgetState createState() => _EsVideoPickerWidgetState();
}

class _EsVideoPickerWidgetState extends State<EsVideoPickerWidget> {
  pickVideo() async {
    PickedFile pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    File videoFile = File(pickedFile.path);
    widget.videoPlayerController = VideoPlayerController.file(videoFile)
      ..setLooping(true);
    widget.videoPlayerController.initialize().then((value) {
      widget.onUpdate(widget.videoPlayerController);
      setState(() {});
    });
    widget.videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    EsVideoBloc _esVideoBloc = Provider.of<EsVideoBloc>(context);
    return StreamBuilder<EsVideoState>(
      stream: _esVideoBloc.esVideoStateObservable,
      builder: (context, snapshot) {
        if (!(widget.videoPlayerController?.value?.initialized ?? false)) {
          return InkWell(
            onTap: pickVideo,
            child: Container(
              height: 100.toHeight,
              width: 100.toWidth,
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.add_a_photo),
              ),
            ),
          );
        }
        return Container(
          height: 100.toHeight,
          width: 100.toWidth,
          child: AspectRatio(
            aspectRatio: widget.videoPlayerController.value.aspectRatio,
            child: VideoPlayer(widget.videoPlayerController),
          ),
        );
      },
    );
  }
}
