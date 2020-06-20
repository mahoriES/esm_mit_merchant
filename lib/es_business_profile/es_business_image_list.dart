import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/data/model/es_product.dart';

class EsBusinessProfileImageList extends StatefulWidget {
  final EsBusinessProfileBloc esBusinessProfileBloc;

  EsBusinessProfileImageList(
    this.esBusinessProfileBloc, {
    Key key,
  }) : super(key: key);

  @override
  _EsBusinessProfileImageListState createState() =>
      _EsBusinessProfileImageListState();
}

class _EsBusinessProfileImageListState
    extends State<EsBusinessProfileImageList> {
  File imageFile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsBusinessProfileState>(
        stream: widget.esBusinessProfileBloc.createBusinessObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          var uploadedList = snapshot.data.selectedBusinessInfo.dImages
              .map(
                (EsImages dImage) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Material(
                    elevation: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(dImage.photoUrl,
                          height: 120, width: 120),
                    ),
                  ),
                ),
              )
              .toList();
          var uploadingList =
              List.generate(snapshot.data.uploadingImages.length + 1, (index) {
            if (index == 0) {
              return GestureDetector(
                onTap: widget.esBusinessProfileBloc.selectImage,
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          // size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Material(
                elevation: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.file(snapshot.data.uploadingImages[index - 1].file,
                      height: 120, width: 120),
                ),
              ),
            );
          });

          var listViewChildren = List<Widget>();

          listViewChildren.addAll(uploadingList);
          listViewChildren.addAll(uploadedList);

          return Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: listViewChildren,
            ),
          );
        });
  }
}
