import 'package:scoped_model/scoped_model.dart';

import '../product.dart';
import '../user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  int _selectedProductIndex;
  User _authenticatedUser;

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
      userId: _authenticatedUser.id,
      userEmail: _authenticatedUser.email,
    );
    _products.add(newProduct);
    notifyListeners();
  }
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return _products.where((Product product) => product.isFavourite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return _products[selectedProductIndex];
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  void updateProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    Product updatedProduct = Product(
      title: title,
      description: description,
      image: image,
      price: price,
      userId: selectedProduct.userId,
      userEmail: selectedProduct.userEmail,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);
    notifyListeners();
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
      title: selectedProduct.title,
      description: selectedProduct.description,
      image: selectedProduct.image,
      price: selectedProduct.price,
      isFavourite: newFavouriteStatus,
      userId: selectedProduct.userId,
      userEmail: selectedProduct.userEmail,
    );
    _products[_selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    _selectedProductIndex = null;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'user-id',
      email: email,
      password: password,
    );
  }
}