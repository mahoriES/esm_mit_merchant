import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/es_address_picker_view/widgets/action_button.dart';
import 'package:foore/es_address_picker_view/widgets/topTile.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:provider/provider.dart';

class ConfirmLocationCard extends StatelessWidget {
  final VoidCallback goToAddressDetails;
  const ConfirmLocationCard({@required this.goToAddressDetails, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    EsAddressBloc _esAddressBloc =
        Provider.of<EsAddressBloc>(context, listen: false);

    return StreamBuilder<EsAddressState>(
      stream: _esAddressBloc.esAddressStateObservable,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.all(20.toWidth),
          color: AppColors.pureWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TopTile(AppTranslations.of(context)
                  .text("address_page_select_location")),
              SizedBox(height: 14.toHeight),
              Text(
                AppTranslations.of(context)
                    .text("address_page_your_location")
                    .toUpperCase(),
                style: AppTextStyles.body2Faded,
              ),
              SizedBox(height: 8.toHeight),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.mainColor,
                  ),
                  SizedBox(width: 8.toWidth),
                  Expanded(
                    child: Text(
                      snapshot.data?.prettyAddress ?? "",
                      style: AppTextStyles.body1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.toHeight),
              ActionButton(
                text: AppTranslations.of(context)
                    .text("address_page_confirm_location"),
                onTap: goToAddressDetails,
                isDisabled: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
