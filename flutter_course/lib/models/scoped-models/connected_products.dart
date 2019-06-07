import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth.dart';
import '../location.dart';
import '../product.dart';
import '../user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  String _selectedProductId;
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

  String get selectedProductId {
    return _selectedProductId;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    return http
        .get(
      'https://fluttercourse-c2b8e.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
    )
        .then<Null>((http.Response response) {
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
          isFavourite: productData['wishlistUsers'] == null
              ? false
              : (productData['wishlistUsers'] as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id),
          userId: productData['userId'],
          userEmail: productData['userEmail'],
        );
        fetchedProductList.add(product);
      });
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
      _selectedProductId = null;
      _isLoading = false;
      notifyListeners();
      return;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  Future<bool> addProduct(
    String title,
    String description,
    String image,
    double price,
    LocationData location,
  ) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.medicalnewstoday.com/content/images/articles/321/321618/dark-chocolate-and-cocoa-beans-on-a-table.jpg',
      'price': price,
      'userId': _authenticatedUser.id,
      'userEmail': _authenticatedUser.email,
      'loc_lat': location.latitude,
      'loc_lng': location.longitude,
      'loc_address': location.address,
    };
    try {
      final http.Response response = await http.post(
        'https://fluttercourse-c2b8e.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        body: json.encode(productData),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
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
      'https://fluttercourse-c2b8e.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
      body: json.encode(updateData),
    )
        .then<bool>((http.Response response) {
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
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = _selectedProductId;
    _products.removeAt(selectedProductIndex);
    _selectedProductId = null;
    notifyListeners();
    return http
        .delete(
      'https://fluttercourse-c2b8e.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}',
    )
        .then<bool>((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavouriteStatus() async {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      image: selectedProduct.image,
      price: selectedProduct.price,
      isFavourite: newFavouriteStatus,
      userId: selectedProduct.userId,
      userEmail: selectedProduct.userEmail,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
    http.Response response;
    if (newFavouriteStatus) {
      response = await http.put(
        'https://fluttercourse-c2b8e.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
        body: json.encode(true),
      );
    } else {
      response = await http.delete(
        'https://fluttercourse-c2b8e.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        image: selectedProduct.image,
        price: selectedProduct.price,
        isFavourite: !newFavouriteStatus,
        userId: selectedProduct.userId,
        userEmail: selectedProduct.userEmail,
      );
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    }
    selectProduct(null);
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    _selectedProductId = null;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(
    String email,
    String password, [
    AuthMode mode = AuthMode.Login,
  ]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyA8TifPydidNA_Ht--7JpiimOsG2Fbnbpk',
        body: json.encode(authData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyA8TifPydidNA_Ht--7JpiimOsG2Fbnbpk',
        body: json.encode(authData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication success!';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken'],
      );
      setAuthTimeout(int.parse(responseData['expiresIn']));
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString('token', responseData['idToken']);
      preferences.setString('userId', responseData['localId']);
      preferences.setString('userEmail', email);
      preferences.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    } else {
      message = 'Something went wrong.';
    }
    _isLoading = false;
    _userSubject.add(true);
    notifyListeners();
    return {
      'success': !hasError,
      'message': message,
    };
  }

  void autoAuthenticate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String token = preferences.getString('token');
    if (token != null) {
      final String expiryTimeString = preferences.getString('expiryTime');
      final DateTime now = DateTime.now();
      final DateTime expiryTime = DateTime.parse(expiryTimeString);
      if (expiryTime.isBefore(now)) {
        _authenticatedUser = null;
        return;
      }
      final int tokenLifespan = expiryTime.difference(now).inSeconds;
      setAuthTimeout(tokenLifespan);
      final String userId = preferences.getString('userId');
      final String userEmail = preferences.getString('userEmail');
      _authenticatedUser = User(
        id: userId,
        email: userEmail,
        token: token,
      );
      _userSubject.add(true);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('token');
    preferences.remove('userId');
    preferences.remove('userEmail');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
