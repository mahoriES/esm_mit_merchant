import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_categories.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import 'es_add_category.dart';

class EsCategoryPage extends StatefulWidget {
  static const routeName = '/categories';
  EsCategoryPage({Key key}) : super(key: key);

  _EsCategoryPageState createState() => _EsCategoryPageState();
}

class _EsCategoryPageState extends State<EsCategoryPage> {
  EsCategoriesBloc esCategoriesBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esCategoriesBloc == null) {
      this.esCategoriesBloc = EsCategoriesBloc(httpService, businessBloc);
    }
    this.esCategoriesBloc.getCategories();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    addItem() async {
      var result =
          await Navigator.of(context).pushNamed(EsAddCategoryPage.routeName);
      esCategoriesBloc.getCategories();
    }

    selectItems(List<EsCategory> categories) {
      Navigator.of(context).pop(categories);
    }

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.dehaze),
        //   onPressed: () {
        //     Scaffold.of(context).openDrawer();
        //   },
        // ),
        title: Text('Select a category'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addItem,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<EsCategoriesState>(
                    stream: this.esCategoriesBloc.esCategoriesStateObservable,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      if (snapshot.data.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.data.isLoadingFailed) {
                        return SomethingWentWrong(
                          onRetry: this.esCategoriesBloc.getCategories,
                        );
                      } else if (snapshot.data.items.length == 0) {
                        return EmptyList(
                          titleText: 'No categories found',
                          subtitleText:
                              "Press 'Add category' to add new categories",
                        );
                      } else {
                        return ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: 72,
                              // top: 30,
                            ),
                            itemCount: snapshot.data.items.length,
                            itemBuilder: (context, index) {
                              final currentCategory =
                                  snapshot.data.items[index];

                              return CheckboxListTile(
                                onChanged: (bool value) {
                                  this.esCategoriesBloc.setCategorySelected(
                                      currentCategory.categoryId, value);
                                },
                                value: currentCategory.dIsSelected,
                                title: Text(currentCategory.dCategoryName),
                                subtitle:
                                    Text(currentCategory.dCategoryDescription),
                              );
                            });
                      }
                    }),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -15),
        child: StreamBuilder<EsCategoriesState>(
            stream: this.esCategoriesBloc.esCategoriesStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                onPressed:
                    snapshot.data.numberOfSelectedItems > 0 ? () {
                      selectItems(snapshot.data.selectedCategories);
                    } : null,
                child: Container(
                  child: Text(
                    'Select categories',
                    style: Theme.of(context).textTheme.subhead.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
