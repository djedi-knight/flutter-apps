import 'package:scoped_model/scoped_model.dart';

import '../product.dart';
import '../user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> products = [];
  int selProductIndex;
  User authenticatedUser;

  void addProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    Product newProduct = Product(
      title: title,
      description: description,
      image: image,
      price: price,
      userId: authenticatedUser.id,
      userEmail: authenticatedUser.email,
    );
    products.add(newProduct);
    selProductIndex = null;
    notifyListeners();
  }
}
