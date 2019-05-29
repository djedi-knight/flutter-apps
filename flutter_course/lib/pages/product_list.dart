import 'package:flutter/material.dart';

import './product_edit.dart';

class ProductListPage extends StatelessWidget {
  final Function updateProduct;
  final Function deleteProduct;
  final List<Map<String, dynamic>> products;

  ProductListPage(this.products, this.updateProduct, this.deleteProduct);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(products[index]['title']),
            background: Container(color: Colors.red,),
            onDismissed: (DismissDirection direction) {
              deleteProduct(index);
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(products[index]['image']),
                  ),
                  title: Text(products[index]['title']),
                  subtitle: Text('\$' + products[index]['price'].toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ProductEditPage(
                            updateProduct: updateProduct,
                            product: products[index],
                            productIndex: index,
                          );
                        },
                      ));
                    },
                  ),
                ),
                Divider(),
              ],
            ),
          );
        },
        itemCount: products.length,
      ),
    );
  }
}
