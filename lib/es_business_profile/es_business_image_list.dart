import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/model/es_business.dart';

class EsBusinessProfileImageList extends StatefulWidget {
  final EsBusinessProfileBloc esBusinessProfileBloc;
  final bool allowMany; //allow uploading multiple photos

  EsBusinessProfileImageList(
    this.esBusinessProfileBloc, {
    this.allowMany = true,
    Key key,
  }) : super(key: key);

  @override
  _EsBusinessProfileImageListState createState() =>
      _EsBusinessProfileImageListState();
}

class _EsBusinessProfileImageListState
    extends State<EsBusinessProfileImageList> {
  File imageFile;

  List<Widget> getChildrenListView(List<Widget> uploadedList,
      List<Widget> uploadingList, Widget uploadIcon) {
    var listViewChildren = List<Widget>();

    if (widget.allowMany) {
      listViewChildren.addAll(uploadedList);
      listViewChildren.addAll(uploadingList);
      listViewChildren.add(uploadIcon);
    } else {
      if (uploadedList != null && uploadedList.length > 0) {
        listViewChildren.addAll(uploadedList);
      } else if (uploadingList != null && uploadingList.length > 0) {
        listViewChildren.addAll(uploadingList);
      } else {
        listViewChildren.add(uploadIcon);
      }
    }

    return listViewChildren;
  }

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
                      child: Stack(
                        children: <Widget>[
                          Image.network(dImage.photoUrl, height: 60, width: 60),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.cancel),
                              color: Colors.black54,
                              onPressed: () {
                                widget.esBusinessProfileBloc
                                    .removeImage(dImage);
                              },
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList();
          var uploadingList =
              List.generate(snapshot.data.uploadingImages.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Material(
                elevation: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Stack(
                    children: <Widget>[
                      Image.file(snapshot.data.uploadingImages[index].file,
                          height: 60, width: 60),
                      Container(
                        child:
                            !snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                      Container(
                        child:
                            snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      color: Colors.white60,
                                      child: Center(
                                        child: Text(
                                          'Upload failed',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                color: Colors.black,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                      Container(
                        child:
                            snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.cancel),
                                      color: Colors.black54,
                                      onPressed: () {
                                        widget.esBusinessProfileBloc
                                            .removeUploadableImage(snapshot
                                                .data.uploadingImages[index]);
                                      },
                                      iconSize: 20,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });

          var uploadIcon = GestureDetector(
            onTap: widget.esBusinessProfileBloc.selectAndUploadImage,
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  height: 60,
                  width: 60,
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

          return Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  getChildrenListView(uploadedList, uploadingList, uploadIcon),
            ),
          );
        });
  }
}
