import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/es_video_page/widgets/custom_input_field.dart';
import 'package:foore/es_video_page/widgets/es_video_picker_widget.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class EsAddVideo extends StatelessWidget {
  static const String routeName = '/esAddVideoPage';

  final TextEditingController videoNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController thumbnailController = TextEditingController();
  VideoPlayerController videoPlayerController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EsVideoBloc _esVideoBloc;

  bool isThumbNailValid() {
    try {
      int seconds = int.parse(thumbnailController.text);
      return videoPlayerController.value.duration.inSeconds >= seconds;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _esVideoBloc = Provider.of<EsVideoBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Video'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.toHeight,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: EsVideoPickerWidget(videoPlayerController, (c) {
                    videoPlayerController = c;
                  }),
                ),
                SizedBox(
                  height: 30.toHeight,
                ),
                CustomInputField('Video Name', videoNameController),
                SizedBox(
                  height: 20.toHeight,
                ),
                CustomInputField('Description', descriptionController),
                SizedBox(
                  height: 20.toHeight,
                ),
                CustomInputField(
                  'Thumbnail in seconds',
                  thumbnailController,
                  format: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                  inputType: TextInputType.number,
                ),
                SizedBox(
                  height: 30.toHeight,
                ),
                StreamBuilder<EsVideoState>(
                  stream: _esVideoBloc.esVideoStateObservable,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    if (snapshot.data.uploadingVideoFailed) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        ResponseDialogue(
                          'Submit Failed',
                          context,
                          message: snapshot.data.errorMessage,
                          buttonText: 'dismiss',
                        );
                      });
                    }
                    return FoSubmitButton(
                      text: 'Save',
                      onPressed: () {
                        String _errorMessage;
                        if (!formKey.currentState.validate()) {
                          _errorMessage =
                              'Please fill all of the required fields';
                        } else if (!(videoPlayerController
                                ?.value?.initialized ??
                            false)) {
                          _errorMessage = 'Please select a video file';
                        } else if (!isThumbNailValid()) {
                          _errorMessage = 'Invalid Thumbnail';
                        }

                        if (_errorMessage != null) {
                          ResponseDialogue(
                            'Submit Failed',
                            context,
                            message: _errorMessage,
                            buttonText: 'dismiss',
                          );
                        } else {
                          _esVideoBloc.uploadVideo();
                        }
                      },
                      isLoading: snapshot.data.isUploadingVideo,
                      isSuccess: snapshot.data.uploadingVideoSuccess,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
