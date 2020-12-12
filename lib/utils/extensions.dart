import 'package:foore/app_translations.dart';
import 'package:foore/utils/navigation_delegate.dart';

extension LocalizationExtension on String {
  String get localize =>
      AppTranslations.of(NavigationHandler.navigatorKey.currentContext)
          .text(this);
}
