import 'package:foore/app_colors.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;
  const ActionButton({
    @required this.text,
    this.icon,
    @required this.onTap,
    @required this.isDisabled,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.toHeight),
          decoration: BoxDecoration(
            color:
                isDisabled ? AppColors.placeHolderColor : AppColors.pureWhite,
            border: isDisabled
                ? null
                : Border.all(
                    color: AppColors.mainColor,
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Flexible(
                  child: Icon(
                    icon,
                    color: isDisabled
                        ? AppColors.disabledAreaColor
                        : AppColors.mainColor,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  child: Text(
                    text,
                    style: AppTextStyles.sectionHeading2.copyWith(
                      color: isDisabled
                          ? AppColors.disabledAreaColor
                          : AppColors.mainColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
