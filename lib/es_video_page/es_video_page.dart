import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/data/model/es_video_models/es_video_list.dart';
import 'package:foore/es_video_page/es_add_video.dart';
import 'package:foore/es_video_page/es_play_video.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'widgets/es_video_details.dart';

class EsVideoPage extends StatefulWidget {
  @override
  _EsVideoPageState createState() => _EsVideoPageState();
}

class _EsVideoPageState extends State<EsVideoPage> {
  @override
  Widget build(BuildContext context) {
    EsVideoBloc _esVideoBloc = Provider.of<EsVideoBloc>(context);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FoSubmitButton(
            text: 'Add Video',
            onPressed: () =>
                Navigator.of(context).pushNamed(EsAddVideo.routeName)
            //     .then(
            //   (value) {
            //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            //       if (value == true) _esVideoBloc.getVideoList();
            //     });
            //   },
            // ),
            ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: StreamBuilder<EsVideoState>(
          stream: _esVideoBloc.esVideoStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.videoFeedState == VideoFeedState.IDEAL) {
              _esVideoBloc.getVideoList();
            }

            if (snapshot.data.videoFeedState == VideoFeedState.LOADING ||
                snapshot.data.updateVideoState == UpdateVideoState.UPDATING) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.videoFeedState == VideoFeedState.FAILED) {
              return SomethingWentWrong(
                subtitleText: snapshot.data?.errorMessage ?? '',
                onRetry: _esVideoBloc.getVideoList,
              );
            }

            if (snapshot.data.updateVideoState == UpdateVideoState.FAILED) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => ResponseDialogue(
                    'Update Failed',
                    message: snapshot.data.errorMessage,
                    buttonText: 'dismiss',
                  ),
                );
              });
            }

            if (snapshot.data.videoList.results.length == 0) {
              return EmptyList(
                titleText: 'No Videos Uploaded Yet !!',
                subtitleText: "Press 'Add Video' to add new videos",
              );
            }

            return RefreshIndicator(
              onRefresh: _esVideoBloc.getVideoList,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.videoList.results.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.videoList.results[index].status
                          .toUpperCase() ==
                      VideoState.PROCESSING) {
                    return Container();
                  }
                  return Container(
                    color: index % 2 == 0 ? Colors.grey[300] : Colors.white,
                    height: 100.toHeight,
                    padding: EdgeInsets.symmetric(
                      vertical: 5.toHeight,
                      horizontal: 5.toWidth,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                PlayVideoPage.routeName,
                                arguments: PlayVideoPageParam(
                                  snapshot.data.videoList.results[index].content
                                      .video.playUrl,
                                  snapshot.data.videoList.results[index].content
                                      .video.thumbnail,
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Opacity(
                                  opacity: 0.8,
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot
                                            .data
                                            .videoList
                                            .results[index]
                                            .content
                                            .video
                                            ?.thumbnail ??
                                        '',
                                    errorWidget: (context, url, error) =>
                                        Container(),
                                    fit: BoxFit.cover,
                                    height: 100.toHeight,
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 40,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.toWidth,
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data.videoList.results[index].title ??
                                    '',
                                style: TextStyle(
                                  fontSize: 16.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 8.toHeight,
                              ),
                              Text(
                                snapshot.data.videoList.results[index].status
                                        .toUpperCase() ??
                                    '',
                                style: TextStyle(
                                  fontSize: 12.toFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: EsVideoDetailsWidget(
                            snapshot.data.videoList.results[index],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}