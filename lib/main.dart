// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/firebase_options.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/bitacora_page.dart';
import 'package:freeyourself_app/pages/home_groups.dart';
import 'package:freeyourself_app/pages/home_page.dart';
import 'package:freeyourself_app/pages/home_resources.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState(){
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async{
    await HelperFunctions.getUserLoggedInStatus(). then((value) {
      if(value != null){
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? HomePageWithBottomNavBar() : LoginPage(),
    );
  }
}





class HomePageWithBottomNavBar extends StatefulWidget {
  const HomePageWithBottomNavBar({Key? key}) : super(key: key);

  @override
  _HomePageWithBottomNavBarState createState() =>
      _HomePageWithBottomNavBarState();
}

class _HomePageWithBottomNavBarState extends State<HomePageWithBottomNavBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    const HomePage(adiccionesSeleccionadas: []),//aqui se agrego el []
    const Bitacora(),
    const HomePage(adiccionesSeleccionadas: []),
    const Recursos(),
    const HomeGroups(),
  ];

  //lo de sofia antes del boton de angel
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  //aqui empieza del botón
  void _onItemTapped(int index) {
    if (index == 2) {
      _showHelpDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _sendHelpMessage() async {
    // Obtener el nombre de usuario desde Firebase
    String userName =
        await HelperFunctions.getUserNameFromSF() ?? 'Unknown User';

    // Crear el mapa del mensaje
    Map<String, dynamic> chatMessageMap = {
      "message": "Necesito ayuda",
      "sender": userName,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    // Enviar el mensaje a cada grupo
    await FirebaseFirestore.instance
        .collection('groups')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(doc.id)
            .collection('messages')
            .add(chatMessageMap);
      });
    });

    // Mostrar un snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mensaje de ayuda enviado a todos los grupos')),
    );
  }
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            '¿Necesitas ayuda?',
            style: TextStyle(
              fontSize: 28,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Esto enviará un mensaje a todos los grupos a los cuales perteneces. ¿Estás seguro?',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.teal),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 15, horizontal: 40)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                  ),
                  child: Text(
                    'Sí',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    _sendHelpMessage();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey.shade400),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 15, horizontal: 40)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
        );
      },
    );
  }
  //aqui termina lo del boton


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)), // Establecer radio de esquinas
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Bitacora',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.white,
                ),
              ),
              label: 'AYUDA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded),
              label: 'Recursos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Grupos',
            ),

          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.teal.shade900,
          selectedItemColor: Colors.white,
          unselectedFontSize: 15,
          selectedFontSize: 17,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          backgroundColor: const Color.fromARGB(255, 142, 217, 203),
        ),
      ),
    );
  }
}
