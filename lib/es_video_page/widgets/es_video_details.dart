import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/data/model/es_video_models/es_video_list.dart';
import 'package:foore/es_video_page/widgets/update_details_dialogue.dart';
import 'package:provider/provider.dart';

class EsVideoDetailsWidget extends StatefulWidget {
  final VideoFeedResponseResults videoData;
  EsVideoDetailsWidget(this.videoData);

  @override
  _EsVideoDetailsWidgetState createState() => _EsVideoDetailsWidgetState();
}

class _EsVideoDetailsWidgetState extends State<EsVideoDetailsWidget> {
  EsVideoBloc _esVideoBloc;
  bool isPublished;
  String newTitle;

  @override
  void initState() {
    _esVideoBloc = Provider.of<EsVideoBloc>(context, listen: false);
    isPublished = widget.videoData.status == 'PUBLISHED';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
      ),
      onSelected: (v) async {
        if (v == UpdateVideoAction.UPDATE_DETAILS) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UpdateVideoDetailsDialogue(
              widget.videoData.title,
              (v) => newTitle = v,
            ),
          );
          if (newTitle == widget.videoData.title)
            return;
          else {
            _esVideoBloc.updateVideo(
              widget.videoData.postId,
              v,
              newTitle: newTitle,
            );
          }
        } else {
          _esVideoBloc.updateVideo(
            widget.videoData.postId,
            v,
          );
        }
      },
      itemBuilder: (context) => <PopupMenuItem>[
        PopupMenuItem(
          value: isPublished
              ? UpdateVideoAction.UNPUBLISH
              : UpdateVideoAction.PUBLISH,
          child: Text(isPublished ? 'Unpublish' : 'Publish'),
        ),
        PopupMenuItem(
          value: UpdateVideoAction.UPDATE_DETAILS,
          child: Text('Update'),
        ),
        PopupMenuItem(
          value: UpdateVideoAction.DELETE,
          child: Text('Delete'),
        ),
      ],
    );
  }
}
