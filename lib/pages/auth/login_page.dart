// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/register_page.dart';
import 'package:freeyourself_app/pages/home_groups.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 142, 217, 203),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.white),) : SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("FreeYourself", 
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height:8),
                  //logo
                  Image.asset("assets/img/freeyourself_logo.png", height: 300),
                  const SizedBox(height: 10),
                  Text("¡Bienvenido de vuelta!", 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height:30),

                  //Email textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      decoration: textInputDecoration.copyWith(
                        labelText: "Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 142, 217, 203),
                        ),
                      ),
                      onChanged: (val){
                        setState(() {
                          email = val;
                        });
                      },

                      //validation
                      validator: (val){
                        return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val!) 
                          ? null : 
                          "Ingresa un email correcto";
                      },
                    ),
                  ),
                  SizedBox(height:25),

                  //password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      obscureText: true,
                      decoration: textInputDecoration.copyWith(
                        labelText: "Contraseña",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color.fromARGB(255, 142, 217, 203),
                        ),
                      ),
                      validator: (val){
                        if (val!.length < 6) {
                          return "La contraseña debe de tener almenos 6 caracteres";
                        } else{
                          return null;
                        }
                      },
                      onChanged: (val){
                        setState(() {
                          password = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  //boton iniciar sesion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 29, 144, 135).withOpacity(0.85), 
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))
                        ),
                        child: const Text(
                          "Iniciar Sesión",
                          style:
                          TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          login();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  //¿No tienes una cuenta?¡Registrate ahora!
                  Text.rich(
                    TextSpan(
                      text: "¿No tienes una cuenta? ",
                      style: TextStyle(
                        color:Colors.grey[900],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "¡Regístrate ahora!",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = (){
                            nextScreen(context, const RegisterPage());
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  login() async{
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
    });
    await authService
      .loginWithUserNameandPassword(email, password)
      .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);
          
          // saving the values to shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          
          nextScreenReplace(context, const HomePageWithBottomNavBar());
        } else {
            showSnackbar(context, Colors.red, "No existe una cuenta con esos datos.");
            setState(() {
              _isLoading = false;
            }
          );
        }
    });
  }}
}