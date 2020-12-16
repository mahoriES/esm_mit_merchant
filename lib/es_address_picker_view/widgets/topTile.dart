import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';

class TopTile extends StatelessWidget {
  final String title;
  const TopTile(
    this.title, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.topTileTitle,
        ),
        TextButton(
          child: Icon(
            Icons.clear,
            color: AppColors.mainColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
