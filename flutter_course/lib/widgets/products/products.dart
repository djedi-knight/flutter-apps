import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/scoped-models/main.dart';
import '../../models/product.dart';
import './product_card.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index]),
        itemCount: products.length,
      );
    } else {
      productCards = Center(child: Text('No Products Found'));
    }
    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');
    return ScopedModelDescendant<MainModel>(
      builder: (
        BuildContext context,
        Widget child,
        MainModel model,
      ) {
        return _buildProductList(model.displayedProducts);
      },
    );
  }
}
