import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  //globlakey nos permite hacer referencia a nuestros formularios
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();

  String email = '';
  String password = '';

  //hacemos una listener para el cambio de texto al boton
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    // print(formkey.currentState?.validate());
    // print('$email - $password');
    return formkey.currentState?.validate() ?? false;
  }
}
