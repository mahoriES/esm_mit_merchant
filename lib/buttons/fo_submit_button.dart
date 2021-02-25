import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';

class FoSubmitButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool isSuccess;
  final bool isEnabled;
  final Function onPressed;
  final Color color;
  const FoSubmitButton({
    this.text,
    this.isLoading,
    this.isSuccess,
    this.isEnabled = true,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess == true) {
      return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 45,
        ),
        color: Colors.white,
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(1.0),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
            Container(
                padding: EdgeInsets.only(
                  left: 15.0,
                ),
                child: new Text(
                  "Success",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                )),
          ],
        ),
      );
    }
    if (isLoading == true) {
      return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 60,
        ),
        onPressed: null,
        child: Container(
            height: 22,
            width: 22,
            child: Center(child: CircularProgressIndicator())),
      );
    }
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 45,
      ),
      onPressed: isEnabled ? onPressed : null,
      color: isEnabled
          ? (color ?? Theme.of(context).primaryColor)
          : EsamudaayTheme.of(context).colors.disabledAreaColor,
      child: Container(
        child: Text(text),
      ),
    );
  }
}
