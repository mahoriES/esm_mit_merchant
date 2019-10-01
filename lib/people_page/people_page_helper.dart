import 'package:foore/data/model/unirson.dart';

class PeoplePageHelper {
  static String getUnirsonTitleText(UnirsonItem unirsonItem) {
    if (unirsonItem.fullName != null && unirsonItem.fullName != '') {
      return unirsonItem.fullName;
    } else {
      return unirsonItem.countryPhone != null
          ? unirsonItem.countryPhone
          : 'User';
    }
  }

  static String getUnirsonSubtitleText(UnirsonItem unirsonItem) {
    if (unirsonItem.fullName != null && unirsonItem.fullName != '') {
      return unirsonItem.countryPhone != null ? unirsonItem.countryPhone : '';
    }
    return '';
  }

  static bool isShowUnirsonSubtitle(UnirsonItem unirsonItem) {
    if (getUnirsonSubtitleText(unirsonItem) != '') {
      return true;
    }
    return false;
  }

  static String getUnirsonNameIconText(UnirsonItem unirsonItem) {
    if (unirsonItem.fullName != null && unirsonItem.fullName != '') {
      if (unirsonItem.fullName.length > 1) {
        return unirsonItem.fullName.substring(0, 1).toUpperCase();
      } else {
        return '';
      }
    }
    return '';
  }

  static bool isShowUnirsonNameIcon(UnirsonItem unirsonItem) {
    if (getUnirsonNameIconText(unirsonItem) != '') {
      return true;
    }
    return false;
  }

  static String getUnirsonLastInteractionText(UnirsonItem unirsonItem) {
    return '';
  }
}
