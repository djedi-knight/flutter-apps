import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../product.dart';
import '../user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  int _selectedProductIndex;
  User _authenticatedUser;
  bool _isLoading = false;
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

  Future<Null> addProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.medicalnewstoday.com/content/images/articles/321/321618/dark-chocolate-and-cocoa-beans-on-a-table.jpg',
      'price': price,
    };
    return http
        .post(
      'https://fluttercourse-c2b8e.firebaseio.com/products.json',
      body: json.encode(productData),
    )
        .then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      Product newProduct = Product(
        id: responseData['name'],
        title: title,
        description: description,
        image: image,
        price: price,
        userId: _authenticatedUser.id,
        userEmail: _authenticatedUser.email,
      );
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> updateProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.medicalnewstoday.com/content/images/articles/321/321618/dark-chocolate-and-cocoa-beans-on-a-table.jpg',
      'price': price,
      'userId': selectedProduct.userId,
      'userEmail': selectedProduct.userEmail,
    };
    return http
        .put(
      'https://fluttercourse-c2b8e.firebaseio.com/products/${selectedProduct.id}.json',
      body: json.encode(updateData),
    )
        .then((http.Response response) {
      Product updatedProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: image,
        price: price,
        userId: selectedProduct.userId,
        userEmail: selectedProduct.userEmail,
      );
      _products[selectedProductIndex] = updatedProduct;
      _isLoading = false;
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selectedProductIndex = null;
    notifyListeners();
    http
        .delete(
            'https://fluttercourse-c2b8e.firebaseio.com/products/$deletedProductId.json')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    return http
        .get('https://fluttercourse-c2b8e.firebaseio.com/products.json')
        .then((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          image: productData['image'],
          userId: productData['userId'],
          userEmail: productData['userEmail'],
        );
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
    });
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

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
