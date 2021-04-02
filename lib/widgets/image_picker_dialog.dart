import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialog extends StatelessWidget {
  static final showImagePickerBottomSheet =
      (BuildContext context) => showModalBottomSheet(
            context: context,
            builder: (context) => ImagePickerDialog(),
          );

  const ImagePickerDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title:
                Text(AppTranslations.of(context).text('image_picker_camera')),
            onTap: () async {
              final pickedFile = await ImagePicker().getImage(
                source: ImageSource.camera,
                imageQuality: 25,
              );
              Navigator.pop(context, pickedFile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title:
                Text(AppTranslations.of(context).text('image_picker_gallery')),
            onTap: () async {
              final pickedFile = await ImagePicker().getImage(
                source: ImageSource.gallery,
                imageQuality: 25,
              );
              Navigator.pop(context, pickedFile);
            },
          ),
        ],
      ),
    );
  }
}
