import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:foore/app_colors.dart';

///The [ImageCropperView] class uses the plugin to show two native UI components
///(based on uCrop and TOCropViewController)
class ImageCropperView {
  ///A singleton instance of the [ImageCropperView] hence only one instance of
  ///this class exists at all times.
  static ImageCropperView _instance;

  ImageCropperView._internal();

  /////////////////////////////////////////////////////////////////////////////
  ///Since this package uses two different native libraries, it allows granular
  ///control for each of the (native) libraries. This can be specified respectively
  ///for the platform using the [AndroidUiSettings] and [IOSUiSettings] classes
  ///to define the UI look and feel!
  /////////////////////////////////////////////////////////////////////////////
  static AndroidUiSettings _androidUiSettings = AndroidUiSettings(
    toolbarTitle: 'Upload',
    toolbarColor: AppColors.appBarColor,
    ///The background color of toolbar for scaling and specifying the rotation
    toolbarWidgetColor: AppColors.pureWhite,
    cropGridColumnCount: 3,
    cropGridRowCount: 3,
    ///Stroke width for the overall frame for the picture
    cropFrameStrokeWidth: 3,
    ///[lockAspectRatio] is essential to keep the aspect ratio locked at 1:1
    lockAspectRatio: true,
    showCropGrid: true,
    ///The background color for the cropper view screen
    backgroundColor: AppColors.blackTextColor,
    hideBottomControls: false,
  );

  static IOSUiSettings _iosUiSettings = IOSUiSettings(
    minimumAspectRatio: 1.0,
    //Prevents the user from changing the aspect ratio
    aspectRatioLockEnabled: true,
    //We need to show the navigation bar to let the user pop back
    hidesNavigationBar: false,
    //Prevents the user from resetting the aspect ratio
    resetAspectRatioEnabled: false,
    //The cancel button confirms if the user
    showCancelConfirmationDialog: false,
    resetButtonHidden: false,
  );

  static ImageCropperView getInstance() {
    if (_instance == null) {
      _instance = ImageCropperView._internal();
    }
    return _instance;
  }

  static Future<File> getSquareCroppedImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ///[aspectRatio] specifies the pre-defined aspect ratio (square in our case)
      ///and we won't be allowing the user to change this in the next screen
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: _androidUiSettings,
      iosUiSettings: _iosUiSettings,
    );
    return croppedFile;
  }
}
