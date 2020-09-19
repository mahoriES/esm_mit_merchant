import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/es_video_page/es_add_video.dart';
import 'package:foore/es_video_page/es_play_video.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

class EsVideoPage extends StatefulWidget {
  @override
  _EsVideoPageState createState() => _EsVideoPageState();
}

class _EsVideoPageState extends State<EsVideoPage> {
  EsVideoBloc _esVideoBloc;

  @override
  Widget build(BuildContext context) {
    _esVideoBloc = Provider.of<EsVideoBloc>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EsAddVideo.routeName);
              },
            ),
          ],
        ),
        floatingActionButton: FoSubmitButton(
          text: 'Add Video',
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

            if (!(snapshot.data.isLoadingVideoList ||
                snapshot.data.isLoadingVideoList ||
                snapshot.data.isLoadingVideoList)) {
              _esVideoBloc.getVideoList();
            }

            if (snapshot.data.isLoadingVideoList) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.loadingVideoListFailed) {
              return SomethingWentWrong(
                subtitleText: snapshot.data.errorMessage,
                onRetry: _esVideoBloc.getVideoList,
              );
            }

            if (snapshot.data.videoList.isEmpty) {
              return EmptyList(
                titleText: 'No Videos Uploaded Yet !!',
                subtitleText: "Press 'Add Video' to add new videos",
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.videoList.length,
              itemBuilder: (context, index) => Container(
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
                          Navigator.of(context)
                              .pushNamed(PlayVideoPage.routeName);
                        },
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.8,
                              child: CachedNetworkImage(
                                imageUrl:
                                    snapshot.data.videoList[index].thumbNailUrl,
                                // placeholder: (context, url) =>
                                //     Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                ),
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
                            snapshot.data.videoList[index].title ?? '',
                            style: TextStyle(
                              fontSize: 16.toFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8.toHeight,
                          ),
                          Text(
                            snapshot.data.videoList[index].description ?? '',
                            style: TextStyle(
                              fontSize: 12.toFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
