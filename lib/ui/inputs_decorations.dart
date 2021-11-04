//se llama UI por las siglas del ingles UserInterface

import 'package:flutter/material.dart';

class InputsDecorations {
  static InputDecoration authInputDecoration(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple)),
        //mandamos los datos para cambiar la informacion de cada input
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),

        //Esto en caso de que no haya un icono que se quiera poner en el input
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.deepPurple,
              )
            : null);
  }
}
