import 'package:flutter/material.dart';
import 'package:foore/es_address_picker_view/add_new_address_view.dart/widgets/address_details_widget.dart';
import 'package:foore/es_address_picker_view/add_new_address_view.dart/widgets/confirm_location_widget.dart';
import 'package:foore/es_address_picker_view/add_new_address_view.dart/widgets/google_map_view.dart';

class AddNewAddressView extends StatefulWidget {
  static const String routeName = "/AddressView";
  AddNewAddressView({Key key}) : super(key: key);

  @override
  _AddNewAddressViewState createState() => _AddNewAddressViewState();
}

class _AddNewAddressViewState extends State<AddNewAddressView> {
  bool showConfirmLocation;

  @override
  void initState() {
    showConfirmLocation = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: showConfirmLocation
          ? ConfirmLocationCard(
              goToAddressDetails: () => setState(() {
                    showConfirmLocation = false;
                  }))
          : AddressDetailsWidget(),
      body: SafeArea(
        child: GoogleMapView(
          goToConfirmLocation: () => setState(() {
            showConfirmLocation = true;
          }),
        ),
      ),
    );
  }
}
