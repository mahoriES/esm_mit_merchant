import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/data/model/es_video_models/es_video_list.dart';
import 'package:foore/es_video_page/widgets/update_details_dialogue.dart';
import 'package:foore/services/sizeconfig.dart';
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
    isPublished = widget.videoData.status == VideoState.PUBLISHED;
    newTitle = widget.videoData.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        size: 25.toFont,
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
          child: Text(isPublished
              ? AppTranslations.of(context).text('video_page_unpublish')
              : AppTranslations.of(context).text('video_page_publish')),
        ),
        PopupMenuItem(
          value: UpdateVideoAction.UPDATE_DETAILS,
          child: Text(AppTranslations.of(context).text('video_page_update')),
        ),
        PopupMenuItem(
          value: UpdateVideoAction.DELETE,
          child: Text(AppTranslations.of(context).text('video_page_delete')),
        ),
      ],
    );
  }
}
