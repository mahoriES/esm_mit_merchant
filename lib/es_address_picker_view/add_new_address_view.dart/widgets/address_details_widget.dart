import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/es_address_picker_view/search_view/search_view.dart';
import 'package:foore/es_address_picker_view/widgets/action_button.dart';
import 'package:foore/es_address_picker_view/widgets/custom_input_field.dart';
import 'package:foore/es_address_picker_view/widgets/topTile.dart';
import 'package:foore/widgets/loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/utils/extensions.dart';

class AddressDetailsWidget extends StatefulWidget {
  const AddressDetailsWidget({Key key}) : super(key: key);

  @override
  _AddressDetailsWidgetState createState() => _AddressDetailsWidgetState();
}

class _AddressDetailsWidgetState extends State<AddressDetailsWidget> {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  EsAddressBloc _esAddressBloc;

  @override
  void initState() {
    _esAddressBloc = Provider.of<EsAddressBloc>(context, listen: false);
    _esAddressBloc.esAddressState.houseNumberController.text = "";
    _esAddressBloc.esAddressState.landMarkController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsAddressState>(
      stream: _esAddressBloc.esAddressStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (snapshot.data?.addressStatus == LaodingStatus.LOADING) {
            LoadingDialog.show();
          } else {
            LoadingDialog.hide();
          }
        });

        return Container(
          padding: EdgeInsets.all(20.toWidth),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TopTile("address_page_enter_address_details".localize),
                SizedBox(height: 14.toHeight),
                Text(
                  ("address_page_your_location".localize).toUpperCase(),
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
                        (snapshot.data?.prettyAddress ?? ""),
                        style: AppTextStyles.body1,
                      ),
                    ),
                    SizedBox(width: 12.toWidth),
                    TextButton(
                      child: Text(
                        ("address_page_change".localize).toUpperCase(),
                        style: AppTextStyles.body2Secondary,
                      ),
                      onPressed: () => Navigator.of(context).pushNamed(
                        SearchAddressView.routeName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.toHeight),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        hintText: "address_page_house_number".localize,
                        controller: snapshot.data.houseNumberController,
                        onChanged: (s) {
                          setState(() {});
                        },
                      ),
                      InputField(
                        hintText: "address_page_landmark".localize,
                        controller: snapshot.data.landMarkController,
                        onChanged: (s) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 20.toHeight),
                    ],
                  ),
                ),
                SizedBox(height: 20.toHeight),
                ActionButton(
                  text: "address_page_save_address".localize,
                  icon: null,
                  onTap: () {
                    print("ontap");
                    if (formKey.currentState.validate()) {
                      debugPrint("is validated **********");
                      Navigator.pop(context);
                      _esAddressBloc.addAddress();
                    }
                  },
                  isDisabled:
                      snapshot.data.landMarkController.text.trim() == "" ||
                          snapshot.data.houseNumberController.text.trim() == "",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
