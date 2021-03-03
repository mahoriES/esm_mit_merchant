class Validators {
  static String percentageValue(String input) {
    double percentage = double.tryParse(input);
    if (input == null || input.isEmpty || percentage > 100)
      return "Invalid Value";
    return null;
  }

  static String nullValueCheck(String input) {
    if (input == null || input.isEmpty) return "Invalid Value";
    return null;
  }
}
