import 'package:flutter/foundation.dart';

class EsdyPrint {
  final String filename;
  final String classname;

  const EsdyPrint({this.filename, this.classname});

  void debug(String message) {
    debugPrint("[${this.filename}][${this.classname}]: $message");
  }
}
