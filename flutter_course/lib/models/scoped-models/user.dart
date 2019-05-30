import '../user.dart';
import './connected_products.dart';

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    authenticatedUser = User(
      id: 'user-id',
      email: email,
      password: password,
    );
  }
}
