class StringConstants {
  static final callUrlLauncher = (String number) => 'tel:$number';
  static final whatsAppIosLauncher = (String number, String message) =>
      "whatsapp://wa.me/$number/?text=${Uri.parse(message)}";
  static final whatsAppAndroidLauncher = (String number, String message) =>
      "whatsapp://send?phone=$number&text=${Uri.parse(message)}";
  static final whatsAppMessage = (String orderNumber, String businessName) =>
      "Order - " + orderNumber + " with " + businessName;

  static const googleApiKey = "AIzaSyBB3evmCD80JI78jt5r70WgBgxCSAK2voY";
  //"AIzaSyBGRrg0YVy9U3SUF34GoAeGbUP_s5RAYAY";

  static const packageName = 'in.foore.mobile';

  static const List<String> placeDetailFields = [
    "address_component",
    "formatted_address",
    "geometry",
  ];

  static const List<String> unitsList = [
    "Piece",
    "Serving",
    "Kg",
    "Gm",
    "Litre",
    "Ml",
    "Dozen",
    "ft",
    "meter",
    "sq. ft."
  ];
}
