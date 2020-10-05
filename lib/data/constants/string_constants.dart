class StringConstants {
  static const List<String> additionalChargesStrings = [
    'Packaging Charge',
    'Service Charge',
    'Late Night Charge'
  ];

  static final callUrlLauncher = (String number) => 'tel:$number';
  static final whatsAppIosLauncher = (String number, String message) =>
      "whatsapp://wa.me/$number/?text=${Uri.parse(message)}";
  static final whatsAppAndroidLauncher = (String number, String message) =>
      "whatsapp://send?phone=$number&text=${Uri.parse(message)}";
}
