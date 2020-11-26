import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_link_sharing.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/data/model/es_video_models/es_video_list.dart';
import 'package:foore/es_video_page/es_add_video.dart';
import 'package:foore/es_video_page/es_play_video.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';
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
          text: AppTranslations.of(context).text('video_page_add_video'),
          onPressed: () =>
              Navigator.of(context).pushNamed(EsAddVideo.routeName),
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
                    AppTranslations.of(context)
                        .text('video_page_update_failed'),
                    message: snapshot.data.errorMessage,
                    buttonText:
                        AppTranslations.of(context).text('video_page_dismiss'),
                  ),
                );
              });
            }

            if (snapshot.data.filteredVideosList.length == 0) {
              return EmptyList(
                titleText: AppTranslations.of(context)
                    .text('video_page_no_videos_uploaded'),
                subtitleText: AppTranslations.of(context)
                    .text('video_page_add_new_videos'),
              );
            }

            return RefreshIndicator(
              onRefresh: _esVideoBloc.getVideoList,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: SizeConfig().screenHeight,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.filteredVideosList.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.filteredVideosList[index].status
                            .toUpperCase() ==
                        VideoState.PROCESSING) {
                      return Container();
                    }
                    return Container(
                      color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
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
                            child: Container(
                              color: Colors.grey[300],
                              child: CachedNetworkImage(
                                imageUrl: snapshot
                                        .data
                                        .filteredVideosList[index]
                                        ?.content
                                        ?.video
                                        ?.thumbnail ??
                                    '',
                                imageBuilder: (context, imageProvider) =>
                                    InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(
                                    PlayVideoPage.routeName,
                                    arguments: PlayVideoPageParam(
                                      snapshot.data.filteredVideosList[index]
                                          .content.video.playUrl,
                                      snapshot.data.filteredVideosList[index]
                                          .content.video.thumbnail,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        size: 40.toFont,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.error)),
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
                                  snapshot.data.filteredVideosList[index]
                                          .title ??
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
                                  snapshot.data.filteredVideosList[index].status
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
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                size: 20.toFont,
                              ),
                              onPressed: () async {
                                EsBusinessesBloc _esBusinessesBloc =
                                    Provider.of<EsBusinessesBloc>(
                                  context,
                                  listen: false,
                                );
                                DynamicLinkParameters linkParameters =
                                    EsDynamicLinkSharing().createVideoLink(
                                        videoId: snapshot.data
                                            .filteredVideosList[index].postId);
                                await EsDynamicLinkSharing().shareLink(
                                  parameters: linkParameters,
                                  text: AppTranslations.of(context).text(
                                      'profile_page_share_link_for_this_video'),
                                  storeName: _esBusinessesBloc
                                      .getSelectedBusinessName(),
                                );
                              },
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: EsVideoDetailsWidget(
                              snapshot.data.filteredVideosList[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
