import 'package:flutter/material.dart';
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

  @override
  void initState() {
    _esBusinessCategoriesBloc =
        Provider.of<EsBusinessCategoriesBloc>(context, listen: false);
    _esBusinessCategoriesBloc.getBusinessCategories();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _selectedBusinessCategories =
        ModalRoute.of(context)?.settings?.arguments ?? <EsBusinessCategory>[];
    _duplicateSelectedBusinessCategories = List.from(_selectedBusinessCategories);
    super.didChangeDependencies();
  }

  void onDone() {
//    Navigator.pop(context, _selectedBusinessCategories);
//    return;
    if (_selectedBusinessCategories.length ==
        _duplicateSelectedBusinessCategories.length) {
      _duplicateSelectedBusinessCategories?.forEach((element) {
        if (!_selectedBusinessCategories.contains(element))
          Navigator.pop(context, _selectedBusinessCategories);
        return;
      });
      Navigator.pop(context, null);
    } else
      Navigator.pop(context, _selectedBusinessCategories);
  }

  void navigateToCategorySearchScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BusinessCategoriesSearchView(
            _esBusinessCategoriesBloc, _selectedBusinessCategories)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Business Categories',
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 3,
      ),
      floatingActionButton: FoSubmitButton(
        text: "Done",
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
                          hintText: 'Search Business Categories',
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
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: snapshot.data.businessCategories
                        .map(
                          (e) => CheckboxListTile(
                            title: Text(e.name),
                            value: isCategorySelected(e.bcat),
                            onChanged: (bool added) {
                              if (added)
                                _selectedBusinessCategories.add(e);
                              else
                                _selectedBusinessCategories.removeWhere(
                                    (element) => element.bcat == e.bcat);
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool isCategorySelected(int bcat) {
    if (_selectedBusinessCategories.isNotEmpty &&
        _selectedBusinessCategories
                .indexWhere((element) => element.bcat == bcat) >
            -1) return true;
    return false;
  }
}
