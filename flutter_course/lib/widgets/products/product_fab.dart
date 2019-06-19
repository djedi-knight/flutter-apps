import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/scoped-models/main.dart';
import '../../models/product.dart';

class ProductFAB extends StatefulWidget {
  final Product product;

  ProductFAB(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (
        BuildContext context,
        Widget child,
        MainModel model,
      ) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: FloatingActionButton(
                heroTag: 'contact',
                mini: true,
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  Icons.mail,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  final url = 'mailto:${widget.product.userEmail}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch!';
                  }
                },
              ),
            ),
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: FloatingActionButton(
                heroTag: 'favourite',
                mini: true,
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  model.selectedProduct.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  model.toggleProductFavouriteStatus();
                },
              ),
            ),
            Container(
              height: 70.0,
              width: 56.0,
              child: FloatingActionButton(
                heroTag: 'options',
                child: Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
          ],
        );
      },
    );
  }
}
