import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/scoped-models/main.dart';
import '../../models/product.dart';
import '../ui_elements/title_default.dart';
import './address_tag.dart';
import './price_tag.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product.title),
          SizedBox(
            width: 8.0,
          ),
          PriceTag(product.price.toString()),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (
        BuildContext context,
        Widget child,
        MainModel model,
      ) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  model.selectProduct(model.allProducts[productIndex].id);
                  Navigator.pushNamed<bool>(
                    context,
                    '/product/' + model.allProducts[productIndex].id,
                  ).then((_) => model.selectProduct(null));
                }),
            IconButton(
              icon: Icon(model.allProducts[productIndex].isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(model.allProducts[productIndex].id);
                model.toggleProductFavouriteStatus();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.image),
              placeholder: AssetImage('assets/background.jpg'),
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ),
          _buildTitlePriceRow(),
          AddressTag(product.location.address),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
