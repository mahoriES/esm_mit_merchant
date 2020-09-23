import 'package:flutter/material.dart';
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
  VideoPlayerController videoPlayerController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EsVideoBloc _esVideoBloc;

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
                  child: EsVideoPickerWidget(
                    (c) {
                      videoPlayerController = c;
                    },
                  ),
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
                        if (formKey.currentState.validate()) {
                          if (!(videoPlayerController?.value?.initialized ??
                              false)) {
                            ResponseDialogue(
                              'Submit Failed',
                              context,
                              message: 'Please select a video file',
                              buttonText: 'dismiss',
                            );
                          } else {
                            _esVideoBloc.uploadVideo();
                          }
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
