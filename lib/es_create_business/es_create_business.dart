import 'dart:async';
import 'package:circles/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_create_business.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_categories/es_business_categories_view.dart';
import 'package:foore/es_business_profile/es_business_profile.dart';
import 'package:foore/es_circles/es_circle_picker_view.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:provider/provider.dart';

class EsCreateBusinessPage extends StatefulWidget {
  static const routeName = '/create-business-page';
  final bool allowBackButton;

  EsCreateBusinessPage({this.allowBackButton = true});

  @override
  EsCreateBusinessPageState createState() => EsCreateBusinessPageState();
}

class EsCreateBusinessPageState extends State<EsCreateBusinessPage>
    with ChipsWidgetMixin {
  final _formKey = GlobalKey<FormState>();
  EsCreateBusinessBloc createBusinessBloc;

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  confirmBusinessAlert(String businessName) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Do you want to create a new business named '$businessName' ?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Confirm'),
              onPressed: () {
                createBusinessBloc.createBusiness(
                  onCreateBusinessSuccess,
                  () => this._showFailedAlertDialog(),
                );
              },
            ),
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return widget.allowBackButton;
  }

  @override
  void initState() {
    createBusinessBloc =
        Provider.of<EsCreateBusinessBloc>(context, listen: false);
    super.initState();
  }

  onCreateBusinessSuccess(EsBusinessInfo businessInfo) {
    var esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    esBusinessesBloc.addCreatedBusiness(businessInfo);
    esBusinessesBloc.setSelectedBusiness(businessInfo);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(EsHomePage.routeName, (_) => false);
  }

  addOrEditBusinessCategories() async {
    debugPrint('Over here to add/edit categories');
    final categories = await Navigator.of(context).pushNamed(
        BusinessCategoriesPickerView.routeName,
        arguments: createBusinessBloc.selectedBusinessCategories);
    if (categories == null) return;
    createBusinessBloc.handleBusinessCategorySelection(categories);
  }

  @override
  Widget build(BuildContext context) {
    return CustomTheme(
      initialThemeType: THEME_TYPES.LIGHT,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.allowBackButton,
          title: Text(
            AppTranslations.of(context).text('create_business_page_title'),
          ),
        ),
        body: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: StreamBuilder<EsCreateBusinessState>(
              stream: createBusinessBloc.createBusinessObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Scrollbar(
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                        ),
                        child: TextFormField(
                          controller: createBusinessBloc.nameEditController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppTranslations.of(context)
                                .text('create_business_page_business_name'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 65,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data.selectedCircle?.clusterName ??
                                        AppTranslations.of(context)
                                            .text('no_circle_selected_msg'),
                                    style: CustomTheme.of(context)
                                        .textStyles
                                        .sectionHeading2,
                                  ),
                                  if (snapshot.data.selectedCircle != null) ...[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      snapshot.data.selectedCircle?.description,
                                      style: CustomTheme.of(context)
                                          .textStyles
                                          .body2Faded,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              width: 0.3,
                              height: 20,
                              color: Colors.grey,
                            ),
                            Expanded(
                              flex: 35,
                              child: FlatButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  final selectedCircle =
                                      await Navigator.pushNamed(
                                          context, CirclePickerView.routeName);
                                  createBusinessBloc
                                      .handleCircleSelection(selectedCircle);
                                },
                                child: Text(snapshot.data.selectedCircle == null
                                    ? AppTranslations.of(context)
                                        .text('select_circle_action')
                                    : AppTranslations.of(context)
                                        .text('change_circle_action')),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          left: 20,
                          right: 20,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          AppTranslations.of(context)
                              .text("profile_page_bcats"),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      getBusinessCategoriesWidget(snapshot
                          .data.businessCategories
                          .map((e) => e.name)
                          .toList()),
                    ],
                  ),
                );
              }),
        ),
        floatingActionButton: StreamBuilder<EsCreateBusinessState>(
            stream: createBusinessBloc.createBusinessObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return FoSubmitButton(
                text: AppTranslations.of(context)
                    .text('create_business_page_save'),
                onPressed: (snapshot.data.selectedCircle == null ||
                        createBusinessBloc.nameEditController.text.isEmpty ||
                        snapshot.data.businessCategories.isEmpty)
                    ? null
                    : () {
                        if (this._formKey.currentState.validate()) {
                          confirmBusinessAlert(
                              createBusinessBloc.nameEditController.text);
                        }
                      },
                isLoading: snapshot.data.isSubmitting,
              );
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget getBusinessCategoriesWidget(List<String> businessCategoriesNamesList) {
    return getChipTextListWidget(
        "+ " + AppTranslations.of(context).text("profile_page_add_bcats"),
        businessCategoriesNamesList,
        null,
        addOrEditBusinessCategories,
        Icons.edit);
  }
}
