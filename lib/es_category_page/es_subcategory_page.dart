import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_categories.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/es_category_page/es_add_subcategory.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';

class EsSabCategoryParam {
  final EsCategory parentCategory;
  final EsCategoriesBloc esCategoriesBloc;
  EsSabCategoryParam({this.esCategoriesBloc, this.parentCategory});
}

class EsSubCategoryPage extends StatefulWidget {
  static const routeName = '/sub-categories';
  final EsCategory parentCategory;
  final EsCategoriesBloc esCategoriesBloc;

  EsSubCategoryPage(this.parentCategory, this.esCategoriesBloc);

  //EsSubCategoryPage({Key key}) : super(key: key);

  _EsSubCategoryPageState createState() => _EsSubCategoryPageState();
}

class _EsSubCategoryPageState extends State<EsSubCategoryPage> {
  //EsCategoriesBloc esCategoriesBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    //final httpService = Provider.of<HttpService>(context);
    //final businessBloc = Provider.of<EsBusinessesBloc>(context);
    //this.esCategoriesBloc = Provider.of<EsCategoriesBloc>(context);
    //if (this.esCategoriesBloc == null) {
    //  this.esCategoriesBloc = EsCategoriesBloc(httpService, businessBloc);
    //}
    //this.esCategoriesBloc.getCategories();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    addItem() async {
      var result = await Navigator.of(context).pushNamed(
          EsAddSubCategoryPage.routeName,
          arguments: EsAddSubCategoryPageParams(
              this.widget.parentCategory.categoryId,
              this.widget.parentCategory.categoryName));
      if (result != null) {
        this.widget.esCategoriesBloc.addUserCreatedCategory(result);
      }
      //esCategoriesBloc.getCategories();
    }

    selectItems(List<EsCategory> categories) {
      Navigator.of(context).pop(categories);
    }

    goBack() {
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.dehaze),
        //   onPressed: () {
        //     Scaffold.of(context).openDrawer();
        //   },
        // ),
        title: Text(this.widget.parentCategory.categoryName),
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
                    stream: this
                        .widget
                        .esCategoriesBloc
                        .esCategoriesStateObservable,
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
                          onRetry: this.widget.esCategoriesBloc.getCategories,
                        );
                      } else if (snapshot.data
                              .getSubCategories(
                                  this.widget.parentCategory.categoryId)
                              .length ==
                          0) {
                        return EmptyList(
                          titleText: AppTranslations.of(context)
                              .text('category_page_no_categories_found'),
                          subtitleText: AppTranslations.of(context).text(
                              'category_page_no_categories_found_message'),
                        );
                      } else {
                        return ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: 72,
                              // top: 30,
                            ),
                            itemCount: snapshot.data
                                .getSubCategories(
                                    this.widget.parentCategory.categoryId)
                                .length,
                            itemBuilder: (context, index) {
                              final currentCategory = snapshot.data
                                  .getSubCategories(this
                                      .widget
                                      .parentCategory
                                      .categoryId)[index];

                              /*return ListTile(
                                  title: Text(currentCategory.dCategoryName),
                                  trailing: Icon(Icons.chevron_right));*/

                              return CheckboxListTile(
                                onChanged: (bool value) {
                                  this
                                      .widget
                                      .esCategoriesBloc
                                      .setCategorySelected(
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
      /*
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
                onPressed: snapshot.data.numberOfSelectedItems > 0
                    ? () {
                        selectItems(snapshot.data.selectedCategories);
                      }
                    : null,
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
      */
    );
  }
}
