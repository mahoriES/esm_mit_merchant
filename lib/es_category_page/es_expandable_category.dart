import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_categories.dart';
import 'package:foore/data/model/es_categories.dart';
import '../app_translations.dart';
import 'es_add_subcategory.dart';

class EsExpandableCategory extends StatelessWidget {
  final EsCategory esCategory;
  final EsCategoriesBloc esCategoriesBloc;
  EsExpandableCategory(this.esCategory, this.esCategoriesBloc, {Key key})
      : super(key: key);

  addSubcategory(BuildContext context, EsCategory selectedCategory) async {
    final result = await Navigator.of(context).pushNamed(
        EsAddSubCategoryPage.routeName,
        arguments: EsAddSubCategoryPageParams(
            selectedCategory.categoryId, selectedCategory.categoryName));
    if (result != null) {
      this.esCategoriesBloc.addUserCreatedCategory(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        child: InkWell(
          onTap: () {
            esCategoriesBloc.setCategoryExpanded(
              esCategory.categoryId,
              !esCategory.dIsExpanded,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Container(
                  height: 25,
                  width: 25,
                  child: Transform.rotate(
                    angle: esCategory.dIsExpanded ? pi / 2 : 0,
                    child: Icon(Icons.chevron_right),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EsCategoryItemWidget(
                      description: esCategory.dCategoryDescription,
                      imageUrl: esCategory.dImageUrl,
                      name: esCategory.dCategoryName,
                      onTap: () {
                        esCategoriesBloc.setCategoryExpanded(
                          esCategory.categoryId,
                          !esCategory.dIsExpanded,
                        );
                      },
                      isShowImage: true,
                    ),
                    esCategory.dIsExpanded
                        ? EsSubCategoryList(
                            esCategory.categoryId,
                            esCategoriesBloc,
                            () => addSubcategory(context, esCategory))
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EsSubCategoryList extends StatelessWidget {
  final int parentCategoryId;
  final EsCategoriesBloc esCategoriesBloc;
  final Function addSubcategory;
  const EsSubCategoryList(
    this.parentCategoryId,
    this.esCategoriesBloc,
    this.addSubcategory, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsCategoriesState>(
      stream: esCategoriesBloc.esCategoriesStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...snapshot.data
                  .getSubCategories(parentCategoryId)
                  .map((subCategory) => EsCategoryItemWidget(
                        name: subCategory.categoryName,
                        description: subCategory.categoryDescription,
                        imageUrl: subCategory.dImageUrl,
                        isSelected: subCategory.dIsSelected,
                        isShowImage: false,
                        onSelected: (isSelected) {
                          // esCategoriesBloc.setCategorySelected(
                          //     subCategory.categoryId, isSelected);
                          Navigator.of(context).pop([subCategory]);
                        },
                      ))
                  .toList(),
              FlatButton(
                onPressed: () {
                  addSubcategory();
                },
                child: Text(
                  '+ ' +
                      AppTranslations.of(context)
                          .text('category_page_add_sub_category'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]);
      },
    );
  }
}

class EsCategoryItemWidget extends StatelessWidget {
  final String name;
  final Function onTap;
  final String imageUrl;
  final String description;
  final isShowImage;
  final Function(bool) onSelected;
  final isSelected;
  const EsCategoryItemWidget(
      {this.name,
      this.imageUrl,
      this.description,
      this.onTap,
      this.isSelected = false,
      this.onSelected,
      this.isShowImage = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (onSelected != null) {
          onSelected(!isSelected);
        } else if (onTap != null) {
          onTap();
        }
      },
      leading: isShowImage
          ? Material(
              elevation: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  height: 60,
                  width: 60,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    fit: BoxFit.fill,
                    errorWidget: (_, __, ___) => placeHolderImage,
                    placeholder: (_, __) => placeHolderImage,
                  ),
                ),
              ),
            )
          : null,
      title: name != null
          ? Text(
              name ?? '',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: ListTileTheme.of(context).textColor,
                  ),
            )
          : null,
      subtitle: description != null
          ? Text(
              description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).textTheme.caption.color,
                  ),
            )
          : null,
      // trailing: onSelected != null
      //     ? Checkbox(
      //         value: isSelected,
      //         onChanged: onSelected != null ? onSelected : (selected) {},
      //       )
      //     : null,
      trailing: onSelected != null
          ? RaisedButton(
              onPressed: () {
                // addSubcategory();
                onSelected(true);
              },
              child: Text(
                'Select',
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }

  Widget get placeHolderImage {
    return Image.asset(
      'assets/category_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}
