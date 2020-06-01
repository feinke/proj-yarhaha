import 'package:flutter/material.dart';
import 'package:proj_yarhaha/amiiboPost.dart';
import 'package:transparent_image/transparent_image.dart';


class AmiiboDetail extends StatelessWidget {
  final AmiiboPost amiiboPost;

  AmiiboDetail({Key key, @required this.amiiboPost}) : super(key: key);

  Stack _imagePlaceholder(String image) {
    return Stack(
      children: <Widget>[
        Center(child: CircularProgressIndicator()),
        Center(child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: image))
      ],
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text(amiiboPost.name)),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: _imagePlaceholder(amiiboPost.image),
      )
    );
  }
}