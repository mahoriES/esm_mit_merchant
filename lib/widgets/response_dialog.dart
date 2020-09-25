import 'package:flutter/material.dart';
import 'package:foore/services/sizeconfig.dart';

class ResponseDialogue extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Function onTap;

  ResponseDialogue(
    this.title, {
    this.message,
    this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        if (onTap != null) onTap();
        return true;
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.toWidth,
            vertical: 20.toHeight,
          ),
          margin: EdgeInsets.symmetric(horizontal: 50.toWidth),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(20.toFont),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? '',
                style: TextStyle(
                  fontSize: 16.toFont,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              Text(
                message ?? '',
                style: TextStyle(
                  fontSize: 12.toFont,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(
                height: 40.toHeight,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onTap != null) onTap();
                  },
                  child: Text(
                    buttonText ?? 'Okay',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
