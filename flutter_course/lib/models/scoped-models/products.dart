import '../product.dart';
import './connected_products.dart';

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return products.where((Product product) => product.isFavourite).toList();
    }
    return List.from(products);
  }

  int get selectedProductIndex {
    return selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return products[selectedProductIndex];
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
    products[selectedProductIndex] = updatedProduct;
    selProductIndex = null;
    notifyListeners();
  }

  void deleteProduct() {
    products.removeAt(selectedProductIndex);
    selProductIndex = null;
    notifyListeners();
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    // final Product updatedProduct = Product(
    //   title: selectedProduct.title,
    //   description: selectedProduct.description,
    //   image: selectedProduct.image,
    //   price: selectedProduct.price,
    //   isFavourite: newFavouriteStatus,
    //   userId: selectedProduct.userId,
    //   userEmail: selectedProduct.userEmail,
    // );
    updateProduct(
      selectedProduct.title,
      selectedProduct.description,
      selectedProduct.image,
      selectedProduct.price,
    );
    notifyListeners();
  }

  void selectProduct(int index) {
    selProductIndex = index;
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    selProductIndex = null;
    notifyListeners();
  }
}
