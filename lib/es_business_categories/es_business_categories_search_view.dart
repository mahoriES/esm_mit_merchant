import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_business_categories.dart';

class BusinessCategoriesSearchView extends StatefulWidget {
  final EsBusinessCategoriesBloc _esBusinessCategoriesBloc;

  BusinessCategoriesSearchView(this._esBusinessCategoriesBloc);

  @override
  _BusinessCategoriesSearchViewState createState() =>
      _BusinessCategoriesSearchViewState();
}

class _BusinessCategoriesSearchViewState
    extends State<BusinessCategoriesSearchView> {
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
          AppTranslations.of(context).text("search_business_category"),
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 3,
      ),
      body: StreamBuilder<EsBusinessCategoriesState>(
        stream: widget._esBusinessCategoriesBloc.businessCategoriesObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty)
                        widget._esBusinessCategoriesBloc
                            .getSearchResultsForBusinessCategoriesByQuery();
                    },
                    controller: widget._esBusinessCategoriesBloc
                        .searchCategoryTextfieldController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText:
                          AppTranslations.of(context).text("search_category"),
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.all(0.0),
                    ),
                  ),
                ),
                if (snapshot.data.searchResultsLoading)
                  Padding(
                      padding: const EdgeInsets.all(30),
                      child: const CircularProgressIndicator()),
                if (!snapshot.data.businessCategoriesLoading)
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        snapshot.data.searchResultsBusinessCategories.length,
                    itemBuilder: (context, index) {
                      final e =
                          snapshot.data.searchResultsBusinessCategories[index];
                      return CheckboxListTile(
                        title: Text(e.name),
                        value: isCategorySelected(e.bcat),
                        onChanged: (bool added) {
                          widget._esBusinessCategoriesBloc
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
    if (widget._esBusinessCategoriesBloc.selectedCategories.isNotEmpty &&
        widget._esBusinessCategoriesBloc.selectedCategories
                .indexWhere((element) => element.bcat == bcat) >
            -1) return true;
    return false;
  }
}
