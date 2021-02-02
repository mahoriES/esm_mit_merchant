class Utils {
  static String getTimeDiffrence(String timeString) {
    DateTime createdAt = DateTime.parse(timeString).toLocal();
    DateTime currentTime = DateTime.now();
    Duration diffrence = currentTime.difference(createdAt);

    String displayText;

    if (diffrence.inSeconds < 60)
      displayText =
          '${diffrence.inSeconds} second${diffrence.inSeconds > 1 ? 's' : ''} ago';
    else if (diffrence.inMinutes < 60)
      displayText =
          '${diffrence.inMinutes} minute${diffrence.inMinutes > 1 ? 's' : ''} ago';
    else if (diffrence.inHours < 24)
      displayText =
          '${diffrence.inHours} hour${diffrence.inHours > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 7)
      displayText =
          '${diffrence.inDays} day${diffrence.inDays > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 31)
      displayText =
          '${diffrence.inDays ~/ 7} week${diffrence.inDays ~/ 7 > 1 ? 's' : ''} ago';
    else
      displayText =
          '${diffrence.inDays ~/ 31} month${diffrence.inDays ~/ 31 > 1 ? 's' : ''} ago';

    return displayText;
  }
}