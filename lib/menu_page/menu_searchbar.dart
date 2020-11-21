import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_products.dart';

import '../app_translations.dart';

class MenuSearchBar extends StatefulWidget {

  final EsProductsBloc productsBloc;

  MenuSearchBar(this.productsBloc);

  @override
  _MenuSearchBarState createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar>
    with AfterLayoutMixin<MenuSearchBar> {
  final searchController = TextEditingController();

   @override
  void afterFirstLayout(BuildContext context) {
     this.searchController.addListener(() {
      widget.productsBloc.onSearchTextChanged(this.searchController);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.only(
            left: 22.0,
            right: 8.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              labelText: (AppTranslations.of(context).text('products_page_search_products')),
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }
}
