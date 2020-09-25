import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_video_models/es_video_list.dart';
import 'package:foore/data/model/es_video_models/es_video_upload_url.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'es_businesses.dart';

class EsVideoBloc {
  final EsVideoState esVideoState = new EsVideoState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  BehaviorSubject<EsVideoState> _subjectEsVideoState;

  EsVideoBloc(this.httpService, this.esBusinessesBloc) {
    _subjectEsVideoState =
        new BehaviorSubject<EsVideoState>.seeded(esVideoState);
  }

  Observable<EsVideoState> get esVideoStateObservable =>
      _subjectEsVideoState.stream;

  Future<void> getVideoList() async {
    try {
      esVideoState.videoFeedState = VideoFeedState.LOADING;
      _updateState();

      Response httpResponse = await httpService.esGet('post/');

      if (httpResponse.statusCode == 200) {
        esVideoState.videoList = VideoFeedResponse.fromJson(
          jsonDecode(httpResponse.body),
        );
        esVideoState.videoFeedState = VideoFeedState.SUCCESS;
        _updateState();
      } else {
        throw ('error :- ' + httpResponse.statusCode.toString());
      }
    } catch (e) {
      print('exception **************************** ${e?.toString()}');
      esVideoState.videoFeedState = VideoFeedState.FAILED;
      esVideoState.errorMessage = e.toString();
      _updateState();
    }
  }

  Future<void> uploadVideo(
    File videoFile,
    String title,
  ) async {
    try {
      esVideoState.addVideoState = AddVideoState.UPLOADING;
      _updateState();

      Response httpResponse = await httpService.esGet('media/video/url');

      if (httpResponse.statusCode == 200) {
        VideoUploadUrlResponse _signedUrlResponse =
            VideoUploadUrlResponse.fromJson(jsonDecode(httpResponse.body));

        await _uploadToSignedUrl(videoFile, _signedUrlResponse, title);

        esVideoState.addVideoState = AddVideoState.SUCCESS;
        esVideoState.videoFeedState = VideoFeedState.IDEAL;

        _updateState();
      } else {
        throw ('error uploadVideo :- ' + httpResponse.statusCode.toString());
      }
    } catch (e) {
      print(
          'uploadVideo exception **************************** ${e?.toString()}');
      esVideoState.addVideoState = AddVideoState.FAILED;
      esVideoState.errorMessage = e.toString();
      _updateState();
    }
  }

  Future<void> _uploadToSignedUrl(
    File videoFile,
    VideoUploadUrlResponse _signedUrlResponse,
    String title,
  ) async {
    Map<String, String> _feilds = {
      'acl': _signedUrlResponse.signedUrlInfo.fields.acl,
      'key': _signedUrlResponse.signedUrlInfo.fields.key,
      'x-amz-algorithm': _signedUrlResponse.signedUrlInfo.fields.xAmzAlgorithm,
      'x-amz-credential':
          _signedUrlResponse.signedUrlInfo.fields.xAmzCredential,
      'x-amz-date': _signedUrlResponse.signedUrlInfo.fields.xAmzDate,
      'policy': _signedUrlResponse.signedUrlInfo.fields.policy,
      'x-amz-signature': _signedUrlResponse.signedUrlInfo.fields.xAmzSignature,
    };
    http.StreamedResponse httpResponse = await httpService.esUploadVideo(
      _signedUrlResponse.signedUrlInfo.url,
      _feilds,
      videoFile,
    );

    if (httpResponse.statusCode == 204) {
      await _sendVideoDetails(title, _signedUrlResponse);
    } else {
      print(
          'error _uploadToSignedUrl :- ' + httpResponse.statusCode.toString());
      throw ('error _uploadToSignedUrl :- ' +
          httpResponse.statusCode.toString());
    }
  }

  Future<void> _sendVideoDetails(
      String title, VideoUploadUrlResponse data) async {
    print(
        'esBusinessesBloc.getSelectedBusinessId() = > ${esBusinessesBloc.getSelectedBusinessId()}');
    Response httpResponse = await httpService.esPost(
      'post/',
      jsonEncode(
        {
          "post_type": "video",
          "title": title,
          "business_id": esBusinessesBloc.getSelectedBusinessId(),
          "content": {
            "video": {
              "video_id": data.videoMeta.videoId,
              "video_url": data.videoMeta.videoUrl,
            }
          }
        },
      ),
    );

    if (httpResponse.statusCode == 201) {
      return;
    } else {
      print('error sendVideoDetails :- ' + httpResponse.statusCode.toString());
      throw ('error sendVideoDetails :- ' + httpResponse.statusCode.toString());
    }
  }

  updateVideo(
    String videoId,
    UpdateVideoAction action, {
    String newTitle,
  }) async {
    try {
      esVideoState.updateVideoState = UpdateVideoState.UPDATING;
      _updateState();

      Response httpResponse;
      switch (action) {
        case UpdateVideoAction.PUBLISH:
          httpResponse = await httpService.esPost(
            'post/$videoId/publish',
            null,
          );
          break;
        case UpdateVideoAction.UNPUBLISH:
          httpResponse = await httpService.esDel('post/$videoId/publish');
          break;
        case UpdateVideoAction.UPDATE_DETAILS:
          httpResponse = await httpService.esPatch(
            'post/$videoId',
            jsonEncode({"title": newTitle}),
          );
          break;
        case UpdateVideoAction.DELETE:
          httpResponse = await httpService.esDel('post/$videoId');
          break;
        default:
          return;
      }

      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) {
        esVideoState.updateVideoState = UpdateVideoState.SUCCESS;
        _updateState();
        getVideoList();
      } else {
        throw ('error :- ' + httpResponse.statusCode.toString());
      }
    } catch (e) {
      print('exception **************************** ${e?.toString()}');
      esVideoState.updateVideoState = UpdateVideoState.FAILED;
      esVideoState.errorMessage = e.toString();
      _updateState();
    }
  }

  _updateState() {
    if (!_subjectEsVideoState.isClosed) {
      _subjectEsVideoState.sink.add(esVideoState);
    }
  }

  dispose() {
    _subjectEsVideoState.close();
  }
}

class EsVideoState {
  VideoFeedState videoFeedState;
  AddVideoState addVideoState;
  UpdateVideoState updateVideoState;
  VideoFeedResponse videoList;
  String errorMessage;
  EsVideoState() {
    this.videoFeedState = VideoFeedState.IDEAL;
    this.addVideoState = AddVideoState.IDEAL;
  }
}

enum UpdateVideoAction { PUBLISH, UNPUBLISH, DELETE, UPDATE_DETAILS }
enum VideoFeedState { IDEAL, LOADING, SUCCESS, FAILED }
enum AddVideoState { IDEAL, UPLOADING, SUCCESS, FAILED }
enum UpdateVideoState { UPDATING, SUCCESS, FAILED }
