import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/es_video_page/widgets/custom_input_field.dart';
import 'package:foore/es_video_page/widgets/es_video_picker_widget.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:provider/provider.dart';

class EsAddVideo extends StatelessWidget {
  static const String routeName = '/esAddVideoPage';

  final TextEditingController videoNameController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    EsVideoBloc _esVideoBloc = Provider.of<EsVideoBloc>(context);
    File videoFile;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text('video_page_add_video')),
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
                      videoFile = c;
                    },
                  ),
                ),
                SizedBox(
                  height: 30.toHeight,
                ),
                CustomInputField(
                    AppTranslations.of(context).text('video_page_video_name'),
                    videoNameController),
                // SizedBox(
                //   height: 20.toHeight,
                // ),
                // CustomInputField('Description', descriptionController),
                SizedBox(
                  height: 30.toHeight,
                ),
                StreamBuilder<EsVideoState>(
                  stream: _esVideoBloc.esVideoStateObservable,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    if (snapshot.data.addVideoState == AddVideoState.FAILED) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => ResponseDialogue(
                            AppTranslations.of(context)
                                .text('video_page_submit_failed'),
                            message: snapshot.data.errorMessage ?? '',
                            buttonText: AppTranslations.of(context)
                                .text('video_page_dismiss'),
                          ),
                        );
                        _esVideoBloc.esVideoState.addVideoState =
                            AddVideoState.IDEAL;
                      });
                    } else if (snapshot.data.addVideoState ==
                        AddVideoState.SUCCESS) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => ResponseDialogue(
                            AppTranslations.of(context)
                                .text('video_page_video_uploaded'),
                            message: AppTranslations.of(context)
                                .text('video_page_video_uploaded_message'),
                            buttonText: AppTranslations.of(context)
                                .text('video_page_okay'),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                        _esVideoBloc.esVideoState.addVideoState =
                            AddVideoState.IDEAL;
                      });
                    }
                    return FoSubmitButton(
                      text: AppTranslations.of(context).text('video_page_save'),
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          if (videoFile == null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => ResponseDialogue(
                                AppTranslations.of(context)
                                    .text('video_page_submit_failed'),
                                message: AppTranslations.of(context)
                                    .text('video_page_select_video_file'),
                                buttonText: AppTranslations.of(context)
                                    .text('video_page_dismiss'),
                              ),
                            );
                          } else {
                            _esVideoBloc.uploadVideo(
                              videoFile,
                              videoNameController.text,
                            );
                          }
                        }
                      },
                      isLoading: snapshot.data.addVideoState ==
                          AddVideoState.UPLOADING,
                      isSuccess:
                          snapshot.data.addVideoState == AddVideoState.SUCCESS,
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
