///Although not being used but still keeping the [AnnoyingChannel] as we might
///later need this. Moreover, it is already added to the resources XML file
class AnnoyingChannel {
  static const CONST_ID = 'annoying_notification_channel_1';
  // Below information will appear as Notification Category in app setting in Android UI.
  static const CONST_NAME = 'Annoying Notifications';
  static const CONST_DESCRIPTION = 'Makes annoying sound for super important notifications';
}

class LocalNotificationsChannel {
  static const CONST_ID = 'local_notification_channel';
  static const CONST_NAME = 'Local Notifications';
  static const CONST_DESCRIPTION = 'Will show local notifications without any sound, only vibration';
}