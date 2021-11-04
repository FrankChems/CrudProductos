import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/ui/inputs_decorations.dart';
import 'package:productos_app/widgets/auth_background.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //invocamos el diseño del background de widgets/auth_background.dart
      body: AuthBackground(
        //auth_background.dart ahora requiere datos para el diseño de nuestro
        //croll
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
              ),
              //invocamos nuestro diseño de tarjeta
              CardContainer(
                //ahora llenamos de información nuestra tarjeta
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    //esto es una instancia que se hace al LofinFormProvider y solo se podrá acceder si se tiene creado el LoginForm()
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: _LoginForm(),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Text("Crear una nueva cuenta"),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

//aqui creamos nuestro formulario
class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //con esto ya tendremos acceso a toda la casle de login_form_provider.dart
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      //Todo esto para la entrata de correo del usuario :O
      child: Form(
        //ahora lo podemos asociar
        key: loginForm.formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              //toda la decoracion fue invocada del archivo ui/inputs_decorations.dart
              decoration: InputsDecorations.authInputDecoration(
                  hintText: 'fra@gmail.com',
                  labelText: 'Correo Electronico',
                  prefixIcon: Icons.alternate_email_rounded),

              //enviamos los datos del loginform
              onChanged: (value) => loginForm.email = value,

              //todo esto se implementa para validar el correo
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);

                //se debe retornar un null si el correo esta bien escrito
                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'El valor ingresado no luce como un correo';
              },
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              //toda la decoracion fue invocada del archivo ui/inputs_decorations.dart
              decoration: InputsDecorations.authInputDecoration(
                  hintText: '******',
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline),

              onChanged: (value) => loginForm.password = value,

              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contraseña debe ser de 6 caracteres';
              },
            ),
            SizedBox(
              height: 30,
            ),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.deepPurple,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text(
                    loginForm.isLoading ? 'Espere...' : 'Ingresar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                //agregamos esa condicion para activar/desactivar el botón
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        // quitar el teclado al enviar la información
                        FocusScope.of(context).unfocus();

                        if (!loginForm.isValidForm()) return;

                        loginForm.isLoading = true;

                        //creamos el await para que tenga tiempo en verse el mensaje
                        await Future.delayed(Duration(seconds: 2));

                        loginForm.isLoading = false;

                        //usamos el pushreplacementNamed para evitar que regrese al formulario
                        Navigator.pushReplacementNamed(context, 'home');
                      })
          ],
        ),
      ),
    );
  }
}
