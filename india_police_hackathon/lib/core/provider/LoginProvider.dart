import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  TextEditingController _userID = TextEditingController();
  TextEditingController _userPIN = TextEditingController();
  bool _isLoginClicked = false;

  // ignore: unnecessary_getters_setters
  bool get isLoginClicked => _isLoginClicked;

  // ignore: unnecessary_getters_setters
  set isLoginClicked(bool value) {
    _isLoginClicked = value;
  }

  TextEditingController get userPIN => _userPIN;

  TextEditingController get userID => _userID;

  GlobalKey<FormState> get loginKey => _loginKey;
}
