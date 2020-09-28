import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/es_video_page/widgets/custom_input_field.dart';
import 'package:foore/services/sizeconfig.dart';

class UpdateVideoDetailsDialogue extends StatefulWidget {
  final String title;
  final Function(String) onUpdate;
  UpdateVideoDetailsDialogue(this.title, this.onUpdate);

  @override
  _UpdateVideoDetailsDialogueState createState() =>
      _UpdateVideoDetailsDialogueState();
}

class _UpdateVideoDetailsDialogueState
    extends State<UpdateVideoDetailsDialogue> {
  TextEditingController titleController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    titleController = TextEditingController(
      text: widget.title,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 20.toWidth, vertical: 30.toHeight),
          margin: EdgeInsets.symmetric(horizontal: 20.toWidth),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: CustomInputField('Update Title', titleController),
              ),
              SizedBox(height: 100.toHeight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FoSubmitButton(
                    text: 'Update',
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        widget.onUpdate(titleController.text);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  FoSubmitButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
