//NUEVO JOSUE TIEMPO-BITACORA

// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/profile_page.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/widgets.dart';
import 'package:intl/intl.dart';

class Bitacora2 extends StatefulWidget {
  const Bitacora2({super.key});

  @override
  State<Bitacora2> createState() => _Bitacora2State();
}

class _Bitacora2State extends State<Bitacora2> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

  //lo de josue para el tiempo 
  final List<String> adicciones = [
    'Cigarro',
    'Alcohol',
    'Cigarrillo electrónico',
    'Marihuana',
    'Metanfetamina',
  ];

  Set<String> adiccionesSeleccionadas = {};

  DateTime fechaActual = DateTime.now();
  String fechaFormateada = DateFormat('dd/MM/yyyy').format(DateTime.now());
  //aqui termina lo del tiempo de josue

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }



  // @override
  // void initState() {
  //   super.initState();
  //   gettingUserData();
  // }

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });

    //list snapshots in stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 142, 217, 203),
        title: Text(
          "Inicio",
          style: TextStyle(
            color: Colors.teal.shade900,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            Image.asset("assets/img/logo_circular.png", height: 180),
            const SizedBox(height: 25),

            Text(
              userName, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              onTap: (){
                nextScreenReplace(context, 
                HomePageWithBottomNavBar());
              },
              selectedColor: Colors.teal.shade500,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.home),
              title: Text(
                "Inicio",
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),
            ListTile(
              onTap: (){
                nextScreenReplace(context, 
                ProfilePage(
                  userName: userName,
                  email: email,
                ));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: Text(
                "Cuenta",
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),
            ListTile(
              onTap: () async{
                showDialog(
                  barrierDismissible: false,
                  context: context, 
                  builder: (context){
                    return AlertDialog(
                      title: Text("Cerrar Sesión"),
                      content: Text("¿Estas seguro de cerrar tu sesión?"),
                      actions: [
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.cancel, 
                          color: Colors.red,
                        ),
                        ),
                        IconButton(onPressed: () async {
                          await authService.signOut();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> LoginPage()),
                          (route) => false);
                        },
                        icon: Icon(
                          Icons.done, 
                          color: Colors.green,
                        ),
                        )
                      ],
                    );
                  }
                );
            
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
           
          ],
        ),
      ),
      //aqui empieza lo de josue
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: 600,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color.fromARGB(255, 6, 166, 153), width: 0.4),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF30D5C8).withOpacity(1.0),
                      const Color(0xFF30D5C8).withOpacity(0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '$fechaFormateada',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Selecciona el tipo de adicción que realizaste en el día (puedes seleccionar uno o varios) y responde el siguiente formulario:",
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: adicciones.map((adiccion) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text(adiccion),
                      value: adiccionesSeleccionadas.contains(adiccion),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            adiccionesSeleccionadas.add(adiccion);
                          } else {
                            adiccionesSeleccionadas.remove(adiccion);
                          }
                        });
                      },
                      
                    ),
                    if (adiccionesSeleccionadas.contains(adiccion))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          Center( 
                            child: Container(
                              width: 330,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(83, 48, 213, 199),
                                borderRadius: BorderRadius.circular(8),
                                
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '¿Porque motivos realizaste esta acción?',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10,),
                                  Container(
                                    width: 343,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFEDF2),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Theme(
                                      data: ThemeData(
                                        canvasColor: const Color(0xFFEFEDF2),   
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(15.0,2.0, 10.0, 8.0),
                                          border: InputBorder.none,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'opcion1',
                                            child: Text('Estrés', style:TextStyle(fontSize: 15)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'opcion2',
                                            child: Text('Enojo', style:TextStyle(fontSize: 15)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'opcion3',
                                            child: Text('Tristeza',style:TextStyle(fontSize: 15)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'opcion4',
                                            child: Text('Ansiedad',style:TextStyle(fontSize: 15)),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          print('Opción seleccionada: $value');
                                        },
                                        hint: const Text(
                                          'Selecciona una opción',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:FontWeight.w400,
                                          )
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  const Text(
                                    '¿Cuantas unidades consumió?',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10,),
                                  Container(
                                    width: 343,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFEDF2),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: TextField(
                                       keyboardType: TextInputType.number, // Define el tipo de teclado como numérico
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      ],
                                      decoration: const InputDecoration(
                                         hintText: 'Ingrese la cantidad',
                                         hintStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                         ),
                                         contentPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical:11),
                                      ),
                                    ),
                                  ),
                                  
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20,),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF30D5C8)), // Cambia "Colors.blue" al color que desees
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white, // Cambia "Colors.white" al color que desees para el texto
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    
    );
  }
}