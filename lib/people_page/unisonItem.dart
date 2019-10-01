import 'package:flutter/material.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/people_page_helper.dart';

class UnirsonItemWidget extends StatelessWidget {
  final UnirsonItem unirsonItem;
  final Function onUnirsonSelected;
  const UnirsonItemWidget(
      {@required this.unirsonItem, this.onUnirsonSelected, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var onClick = () {
      if (this.onUnirsonSelected != null) {
        onUnirsonSelected(unirsonItem);
      }
    };
    return ListTile(
      onTap: onClick,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          height: double.infinity,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: PeoplePageHelper.isShowUnirsonNameIcon(unirsonItem)
              ? Text(
                  PeoplePageHelper.getUnirsonNameIconText(unirsonItem),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                ),
        ),
      ),
      title: Text(PeoplePageHelper.getUnirsonTitleText(unirsonItem)),
      subtitle: PeoplePageHelper.isShowUnirsonSubtitle(unirsonItem)
          ? Text(PeoplePageHelper.getUnirsonSubtitleText(unirsonItem))
          : null,
      trailing: Text(
        PeoplePageHelper.getUnirsonLastInteractionText(unirsonItem),
        style: TextStyle(color: Colors.black45),
      ),
    );
  }
}
