import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EsOrderDetailsImageView extends StatelessWidget {
  final String imageUrl;
  EsOrderDetailsImageView(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              height: double.infinity,
              width: double.infinity,
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
