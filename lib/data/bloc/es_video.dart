import 'package:foore/data/model/es_video_list.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class EsVideoBloc {
  final EsVideoState _esVideoState = new EsVideoState();

  BehaviorSubject<EsVideoState> _subjectEsVideoState;

  EsVideoBloc() {
    _subjectEsVideoState =
        new BehaviorSubject<EsVideoState>.seeded(_esVideoState);
  }

  Observable<EsVideoState> get esVideoStateObservable =>
      _subjectEsVideoState.stream;

  Future<void> getVideoList() async {
    try {
      if (_esVideoState.isLoadingVideoList ||
          _esVideoState.loadingVideoListSuccess ||
          _esVideoState.loadingVideoListFailed) {
        return;
      }
      _esVideoState.isLoadingVideoList = true;
      _esVideoState.loadingVideoListSuccess = false;
      _esVideoState.loadingVideoListFailed = false;
      _updateState();

      //// api logic here.
      await Future.delayed(Duration(seconds: 4));

      _esVideoState.videoList = List.generate(
        6,
        (index) => EsVideoListPayload(
          title: 'Demo Video Title',
          description: 'Here is some description about the video',
          thumbNailUrl: "http://via.placeholder.com/350x150",
        ),
      );
      _esVideoState.isLoadingVideoList = false;
      _esVideoState.loadingVideoListSuccess = true;
      _esVideoState.loadingVideoListFailed = false;
      _updateState();
    } catch (e) {
      _esVideoState.isLoadingVideoList = false;
      _esVideoState.loadingVideoListSuccess = false;
      _esVideoState.loadingVideoListFailed = true;
      _esVideoState.errorMessage = e.toString();
      _updateState();
    }
  }

  Future<void> uploadVideo() async {
    try {
      _esVideoState.isUploadingVideo = true;
      _esVideoState.uploadingVideoFailed = false;
      _esVideoState.uploadingVideoSuccess = false;
      _updateState();

      //// api logic here.
      await Future.delayed(Duration(seconds: 4));

      _esVideoState.uploadingVideoSuccess = true;
      _esVideoState.uploadingVideoFailed = false;
      _esVideoState.isUploadingVideo = false;
      _updateState();
    } catch (e) {
      _esVideoState.isUploadingVideo = false;
      _esVideoState.uploadingVideoFailed = true;
      _esVideoState.uploadingVideoSuccess = false;
      _esVideoState.errorMessage = e.toString();
      _updateState();
    }
  }

  // Future<void> pickVideo() async {
  //   _esVideoState.isVideoSelected = false;
  //   _updateState();
  //   PickedFile file = await ImagePicker().getVideo(source: ImageSource.gallery);
  //   _esVideoState.selectedVideoFile = File(file.path);
  //   _esVideoState.isVideoSelected = true;
  //   _updateState();
  // }

  // Future<void> muxDirectUpload(File file) async {
  //   _esVideoState.isVideoUploading = true;
  //   _updateState();
  //   GenericApiResponse response = await GenericHttpServices().postRequest(
  //     MuxConstants.directUploadUrl,
  //     body: {
  //       "new_asset_settings": {
  //         "playback_policy": "public",
  //       }
  //     },
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": GenericHttpServices().getAuthString(
  //         MuxConstants.accessKey,
  //         MuxConstants.secretKey,
  //       ),
  //     },
  //   );

  //   try {
  //     if (response.statusCode >= 200 && response.statusCode <= 400) {
  //       String authUrl = response.data['data']['url'];
  //       Uri postUri = Uri.parse(authUrl);
  //       HttpClient client = HttpClient(context: SecurityContext.defaultContext);
  //       HttpClientRequest xyz = await client.putUrl(postUri);
  //       await xyz.addStream(file.openRead());
  //       await xyz.flush();
  //       final httpresponse = await xyz.close();
  //       print("codexxx => ${httpresponse.statusCode}");
  //       print("bodyxxx => ${httpresponse.contentLength}");
  //       _esVideoState.videoUploadedSuccessfully = true;
  //     } else
  //       throw ('');
  //   } catch (e) {
  //     print('************************** in catch ${e.toString()}');
  //     _esVideoState.errorMessage = response.erroMessage ?? '';
  //     _esVideoState.videoUploadedSuccessfully = false;
  //   }
  //   _esVideoState.isVideoUploading = false;
  //   _updateState();
  // }

  _updateState() {
    if (!_subjectEsVideoState.isClosed) {
      _subjectEsVideoState.sink.add(_esVideoState);
    }
  }

  dispose() {
    _subjectEsVideoState.close();
  }
}

class EsVideoState {
  bool isLoadingVideoList;
  bool loadingVideoListSuccess;
  bool loadingVideoListFailed;
  bool isUploadingVideo;
  bool uploadingVideoSuccess;
  bool uploadingVideoFailed;
  List<EsVideoListPayload> videoList;
  String errorMessage;
  EsVideoState() {
    this.isLoadingVideoList = false;
    this.loadingVideoListSuccess = false;
    this.loadingVideoListFailed = false;
    this.isUploadingVideo = false;
    this.uploadingVideoSuccess = false;
    this.uploadingVideoFailed = false;
    this.videoList = [];
  }
}
