import 'package:flutter/material.dart';

import '../../models/product.dart';
import './product_card.dart';

class Products extends StatelessWidget {
  final List<Product> products;

  Products(this.products) {
    print('[Products Widget] Constructor');
  }

  Widget _buildProductList() {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
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
    return _buildProductList();
  }
}
