import 'package:scoped_model/scoped_model.dart';

import '../user.dart';

mixin UserModel on Model {
  User _authenticatedUser;

  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'user-id',
      email: email,
      password: password,
    );
  }
}
