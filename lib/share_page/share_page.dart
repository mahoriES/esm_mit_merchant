  
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:foore/buttons/fo_submit_button.dart';


class SharePage extends StatefulWidget {
  SharePage({Key key}) : super(key: key);

  static const routeName = 'share';

  @override
  _SharePageState createState() => _SharePageState();

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => SharePage());
  }
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share"),
      ),
      floatingActionButton: FoSubmitButton(
        text: "Share",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              MaterialButton(
                child: Text('Share text'),
                onPressed: () async => await _shareText(),
              ),
              MaterialButton(
                child: Text('Share image'),
                onPressed: () async => await _shareImage(),
              ),
              MaterialButton(
                child: Text('Share images'),
                onPressed: () async => await _shareImages(),
              ),
              MaterialButton(
                child: Text('Share CSV'),
                onPressed: () async => await _shareCSV(),
              ),
              MaterialButton(
                child: Text('Share mixed'),
                onPressed: () async => await _shareMixed(),
              ),
              MaterialButton(
                child: Text('Share image from url'),
                onPressed: () async => await _shareImageFromUrl(),
              ),
              MaterialButton(
                child: Text('Share sound'),
                onPressed: () async => await _shareSound(),
              ),
            ],
          )),
    );
  }

  Future<void> _shareText() async {
    try {
      Share.text('my text title',
          'This is my text to share with other applications.', 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImage() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/logo-black.png');
      await Share.file(
          'Foore', 'logo-black.png', bytes.buffer.asUint8List(), 'image/png',
          text: 'Sharing Shortcuts and ChooserTarget objects are Direct Share deep links into a specific Activity within your app. ');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImages() async {
    try {
      final ByteData bytes1 = await rootBundle.load('assets/google-icon.png');
      final ByteData bytes2 = await rootBundle.load('assets/logo-black.png');

      await Share.files(
          'esys images',
          {
            'esys.png': bytes1.buffer.asUint8List(),
            'bluedan.png': bytes2.buffer.asUint8List(),
          },
          'image/png');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareCSV() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/addresses.csv');
      await Share.file(
          'addresses', 'addresses.csv', bytes.buffer.asUint8List(), 'text/csv');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareMixed() async {
    try {
      final ByteData bytes1 = await rootBundle.load('assets/logo-black.png');
      final ByteData bytes2 = await rootBundle.load('assets/logo-black.png');
      final ByteData bytes3 = await rootBundle.load('assets/addresses.csv');

      await Share.files(
          'esys images',
          {
            'esys.png': bytes1.buffer.asUint8List(),
            'bluedan.png': bytes2.buffer.asUint8List(),
            'addresses.csv': bytes3.buffer.asUint8List(),
          },
          '*/*',
          text: 'My optional text.');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImageFromUrl() async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(
          'https://shop.esys.eu/media/image/6f/8f/af/amlog_transport-berwachung.jpg'));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareSound() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/cat.mp3');
      await Share.file(
          'Sound', 'cat.mp3', bytes.buffer.asUint8List(), 'audio/*');
    } catch (e) {
      print('error: $e');
    }
  }
}
