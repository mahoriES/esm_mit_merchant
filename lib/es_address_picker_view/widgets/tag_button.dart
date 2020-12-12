import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/services/sizeconfig.dart';

class TagButton extends StatelessWidget {
  final bool isSelected;
  final String tag;
  final VoidCallback onTap;
  const TagButton({
    @required this.isSelected,
    @required this.tag,
    @required this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : AppColors.pureWhite,
          border: Border.all(color: AppColors.mainColor),
          borderRadius: BorderRadius.circular(20.toWidth),
        ),
        child: Center(
          child: Text(
            tag,
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? AppColors.pureWhite : AppColors.mainColor,
            ),
          ),
        ),
      ),
    );
  }
}
