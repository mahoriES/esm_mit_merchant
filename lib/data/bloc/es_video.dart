import 'dart:convert';
import 'dart:io';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/model/es_video_models/es_video_request_data.dart';
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

      Response httpResponse = await httpService.esGet(EsApiPaths.getVideoPath);

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

      Response httpResponse = await httpService.esGet(EsApiPaths.getSignedUrl);

      if (httpResponse.statusCode == 200) {
        VideoUploadUrlResponse _signedUrlResponse =
            VideoUploadUrlResponse.fromJson(jsonDecode(httpResponse.body));

        await _uploadToSignedUrl(videoFile, _signedUrlResponse, title);

        esVideoState.addVideoState = AddVideoState.SUCCESS;
        esVideoState.videoFeedState = VideoFeedState.IDEAL;

        _updateState();
      } else {
        throw ('error :- ' + httpResponse.statusCode.toString());
      }
    } catch (e) {
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
    Map<String, String> _fields =
        CreateVideoUploadPayload(_signedUrlResponse.signedUrlInfo).toJson();
    http.StreamedResponse httpResponse = await httpService.esUploadVideo(
      _signedUrlResponse.signedUrlInfo.url,
      _fields,
      videoFile,
    );

    if (httpResponse.statusCode == 204) {
      await _sendVideoDetails(title, _signedUrlResponse);
    } else {
      throw ('error _uploadToSignedUrl :- ' +
          httpResponse.statusCode.toString());
    }
  }

  Future<void> _sendVideoDetails(
      String title, VideoUploadUrlResponse data) async {
    Response httpResponse = await httpService.esPost(
      EsApiPaths.getVideoPath,
      jsonEncode(
        CreateVideoDetailsPayload(
          title,
          data.videoMeta.videoId,
          data.videoMeta.videoUrl,
          esBusinessesBloc.getSelectedBusinessId(),
        ),
      ),
    );

    if (httpResponse.statusCode == 201) {
      return;
    } else {
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
            EsApiPaths.publishVideo(videoId),
            null,
          );
          break;
        case UpdateVideoAction.UNPUBLISH:
          httpResponse = await httpService.esDel(
            EsApiPaths.publishVideo(videoId),
          );
          break;
        case UpdateVideoAction.UPDATE_DETAILS:
          httpResponse = await httpService.esPatch(
            EsApiPaths.updateVideo(videoId),
            jsonEncode({"title": newTitle}),
          );
          break;
        case UpdateVideoAction.DELETE:
          httpResponse = await httpService.esDel(
            EsApiPaths.updateVideo(videoId),
          );
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
