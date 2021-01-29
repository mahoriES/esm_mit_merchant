import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_business_categories.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_categories/es_business_categories_search_view.dart';
import 'package:provider/provider.dart';

class BusinessCategoriesPickerView extends StatefulWidget {
  static const routeName = "/businessCategoriesPickerView";

  @override
  _BusinessCategoriesPickerViewState createState() =>
      _BusinessCategoriesPickerViewState();
}

class _BusinessCategoriesPickerViewState
    extends State<BusinessCategoriesPickerView> {
  EsBusinessCategoriesBloc _esBusinessCategoriesBloc;
  List<EsBusinessCategory> _selectedBusinessCategories;
  List<EsBusinessCategory> _duplicateSelectedBusinessCategories;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _esBusinessCategoriesBloc =
        Provider.of<EsBusinessCategoriesBloc>(context, listen: false);
    _esBusinessCategoriesBloc.getBusinessCategories();
    _scrollController..addListener(() {
      if(_scrollController.position.pixels / _scrollController
          .position.maxScrollExtent > 0.70){
        _esBusinessCategoriesBloc.getBusinessCategories();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _selectedBusinessCategories =
        ModalRoute.of(context)?.settings?.arguments ?? <EsBusinessCategory>[];
    _duplicateSelectedBusinessCategories =
        List.from(_selectedBusinessCategories);
    _esBusinessCategoriesBloc.selectedBusinessCategories =
        _selectedBusinessCategories;
    super.didChangeDependencies();
  }

  void onDone() {
    if (_esBusinessCategoriesBloc.selectedCategories.length ==
        _duplicateSelectedBusinessCategories.length) {
      _duplicateSelectedBusinessCategories?.forEach((element) {
        if (!_esBusinessCategoriesBloc.selectedCategories.contains(element))
          Navigator.pop(context, _esBusinessCategoriesBloc.selectedCategories);
        return;
      });
      Navigator.pop(context, null);
    } else
      Navigator.pop(context, _esBusinessCategoriesBloc.selectedCategories);
  }

  void navigateToCategorySearchScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BusinessCategoriesSearchView(
            _esBusinessCategoriesBloc)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          AppTranslations.of(context).text("business_categories"),
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 3,
      ),
      floatingActionButton: FoSubmitButton(
        text: AppTranslations.of(context).text("done_category"),
        onPressed: () {
          onDone();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder<EsBusinessCategoriesState>(
        stream: _esBusinessCategoriesBloc.businessCategoriesObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: navigateToCategorySearchScreen,
                    child: IgnorePointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppTranslations.of(context)
                              .text("search_business_category"),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ),
                if (snapshot.data.businessCategoriesLoading)
                  Padding(
                      padding: EdgeInsets.all(30),
                      child: const CircularProgressIndicator()),
                if (!snapshot.data.businessCategoriesLoading)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.businessCategories.length,
                    itemBuilder: (context, index) {
                      final e = snapshot.data.businessCategories[index];
                      return CheckboxListTile(
                        title: Text(e.name),
                        value: isCategorySelected(e.bcat),
                        onChanged: (bool added) {
                          _esBusinessCategoriesBloc
                              .updateCategorySelections(e, added);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool isCategorySelected(int bcat) {
    if (_esBusinessCategoriesBloc.selectedCategories.isNotEmpty &&
        _esBusinessCategoriesBloc.selectedCategories
                .indexWhere((element) => element.bcat == bcat) >
            -1) return true;
    return false;
  }
}
