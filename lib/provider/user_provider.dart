
import 'package:flutter/widgets.dart';


import '../models/user.dart';
import '../resources/auth_method.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  AuthMethod _authMethods = aut;

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
