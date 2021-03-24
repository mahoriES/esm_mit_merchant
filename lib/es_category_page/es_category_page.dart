import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_categories.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/es_category_page/es_subcategory_page.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'es_add_category.dart';
import 'es_expandable_category.dart';

class EsCategoryPage extends StatefulWidget {
  static const routeName = '/categories';
  final List<int> selectedCategoryIds;
  EsCategoryPage({this.selectedCategoryIds});

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
      this.esCategoriesBloc = EsCategoriesBloc(
          httpService, businessBloc, this.widget.selectedCategoryIds);
    }
    this.esCategoriesBloc.getCategories();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    addItem() async {
      final result =
          await Navigator.of(context).pushNamed(EsAddCategoryPage.routeName);
      if (result != null) {
        this.esCategoriesBloc.addUserCreatedCategory(result);
      }
    }

    selectItems(List<EsCategory> categories) {
      Navigator.of(context).pop(categories);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context)
            .text('category_page_select_a_category')),
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
                      } else if (snapshot.data.parentCategories.length == 0) {
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
                              top: 30,
                            ),
                            itemCount: snapshot.data.parentCategories.length,
                            itemBuilder: (context, index) {
                              final currentCategory =
                                  snapshot.data.parentCategories[index];
                              return EsExpandableCategory(
                                  currentCategory, esCategoriesBloc);
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
                onPressed: //snapshot.data.numberOfSelectedItems > 0?
                    () {
                  selectItems(snapshot.data.selectedCategories);
                }
                //: null
                ,
                child: Container(
                  child: Text(
                    AppTranslations.of(context).text('generic_save'),
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
