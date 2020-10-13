import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:foore/app_colors.dart';

///The [ImageCropperView] class uses the plugin to show two native UI components
///(based on uCrop and TOCropViewController)
class ImageCropperView {

  static ImageCropperView _instance ;

  ImageCropperView._internal();

  static AndroidUiSettings _androidUiSettings = AndroidUiSettings(
      toolbarTitle: 'Image Cropper',
      toolbarColor: AppColors.appBarColor,
      toolbarWidgetColor: AppColors.pureWhite,
      cropGridColumnCount: 3,
      cropGridRowCount: 3,
      cropFrameStrokeWidth: 3,
      lockAspectRatio: true,
      showCropGrid: true,
      backgroundColor: AppColors.blackTextColor,
      hideBottomControls: false,
      );

  static IOSUiSettings _iosUiSettings = IOSUiSettings(
    minimumAspectRatio: 1.0,
    aspectRatioLockEnabled: true,

  );

  static ImageCropperView getInstance() {
    if(_instance==null){
      _instance =ImageCropperView._internal();
    }
    return _instance;
  }

  static Future<File> getSquareCroppedImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: _androidUiSettings,
        iosUiSettings: _iosUiSettings,
    );
    return croppedFile;
  }

}