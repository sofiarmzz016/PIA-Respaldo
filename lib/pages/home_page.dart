// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/profile_page.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/widgets.dart';
class HomePage extends StatefulWidget {
  final List<String> adiccionesSeleccionadas;
  const HomePage({Key? key, required this.adiccionesSeleccionadas}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

  //aqui empieza lo de josue
  late Timer _timer;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _tiempoTotal = 0;
  int _tiempoTotal2 = 0;
  late int _totalMinutes = 0;
  String selectedButton = '';
  Color? selectedColor;

  String? selectedOption;

  DateTime? _savedDateTime;
  String _elapsedTime = '0 horas y 0 minutos';

  Map<String, int> valoresPredefinidos = {
  'Cigarro': 1,
  'Alcohol': 2,
  'Cigarrillo electrónico': 3,
  'Marihuana': 4,
  'Metanfetamina': 5,
  'Refresco': 6,
  'Otra': 7,
};

final List<String> adicciones = [
    'Cigarro',
    'Alcohol',
    'Cigarrillo electrónico',
    'Marihuana',
    'Metanfetamina',
    'Refresco'
  ];

  Set<String> adiccionesSeleccionadas = {};
  Map<String, String> elapsedTimes = {};
  Map<String, String> elapsedDays = {};
  Map<String, String> elapsedHours = {};
  Map<String, String> elapsedMinutes = {};
  Map<String, String> elapsedSeconds = {};
  List<String> adiccionesDisponibles = [];
  String? selectedAdiccion;

void startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      _seconds++;
      if (_seconds == 60) {
        _seconds = 0;
        _minutes++;
        if (_minutes == 60) {
          _minutes = 0;
          _hours++;
          if (_hours == 24) {
            _hours = 0;
            _days++;
          }
        }
      }
 
      // if (_seconds == 0 && _minutes == 0 && _hours == 1) {
      //     guardarTiempo(_days, _hours, _minutes, _seconds);
      //   }
    });
  });
}

//checar
// void guardarTiempo(int dias, int horas, int minutos, int segundos) async {
//   try {
//     await FirebaseFirestore.instance.collection('cronometros').add({
//       'dias': dias,
//       'horas': horas,
//       'minutos': minutos,
//       'segundos': segundos,
//     });
//     print('Tiempo guardado en Firestore');
//   } catch (e) {
//     print('Error al guardar tiempo: $e');
//   }
// }


  void stopTimer() {
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    //obtenerAdiccionesDesdeFirestore();
    _calculateElapsedTime();

    _fetchElapsedTimeForEachAdiccion();
    _fetchAvailableAdicciones();
    gettingUserData();
  }


  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

Future<void> _fetchAvailableAdicciones() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('bitacoras').get();
      Set<String> uniqueAdicciones = {};
      for (var doc in querySnapshot.docs) {
        uniqueAdicciones.add(doc['adiccion']);
      }
      setState(() {
        adiccionesDisponibles = uniqueAdicciones.toList();
      });
    } catch (error) {
      print("Error al obtener las adicciones disponibles: $error");
    }
  }

  Future<void> _fetchElapsedTimeForEachAdiccion() async {
    try {
      for (var adiccion in adicciones) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('bitacoras')
            .where('adiccion', isEqualTo: adiccion)
            .orderBy('fecha', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot latestDoc = querySnapshot.docs.first;
          Timestamp latestTimestamp = latestDoc['fecha'];
          DateTime latestDateTime = latestTimestamp.toDate();
          Duration difference = DateTime.now().difference(latestDateTime);
          int differenceInSeconds = difference.inSeconds;
          int remainingSeconds = differenceInSeconds.remainder(60);
          int remainingMinutes = difference.inMinutes.remainder(60);
          int remainingHours = difference.inHours;
          int remainingDays = difference.inDays;

          _tiempoTotal2 = (remainingHours*60)+remainingMinutes;

          setState(() {
            elapsedDays[adiccion] =
                '${remainingDays}';
            elapsedHours[adiccion] =
                '${remainingHours}';
            elapsedMinutes[adiccion] =
                '${remainingMinutes}';
            elapsedSeconds[adiccion] =
                '${remainingSeconds}';
          });
        }
      }
    } catch (error) {
      print("Error al obtener el tiempo transcurrido: $error");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

// void obtenerAdiccionesDesdeFirestore() async {
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('bitacoras').get();
//       List<String> adiccionesList = [];
//       querySnapshot.docs.forEach((doc) {
//         String adiccion = doc['adiccion'];
//         if (!adiccionesList.contains(adiccion)) {
//           adiccionesList.add(adiccion);
//         }
//       });
//       setState(() {
//         adicciones = adiccionesList;
//       });
//     } catch (e) {
//       print('Error al obtener adicciones desde Firestore: $e');
//     }
//   }
//   Future<List<DocumentSnapshot>> getTiempoGuardado() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('cronometros').get();
//       return querySnapshot.docs;
//     } catch (e) {
//       print('Error al recuperar el tiempo guardado: $e');
//       return [];
//     }
//   }
  Future<void> _calculateElapsedTime() async {
    try {
      // Consultar la hora guardada en la base de datos
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('nueva_fecha')
          .doc('hora_guardada')
          .get();

      // Verificar si el documento existe y contiene datos
      if (snapshot.exists && snapshot.data() != null) {
        // Obtener el mapa de datos del documento
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Verificar si el campo 'fecha_hora' existe y no es nulo
        if (data.containsKey('fecha_hora') && data['fecha_hora'] != null) {
          // Obtener la fecha y hora guardada como un objeto Timestamp
          Timestamp savedTimestamp = data['fecha_hora'] as Timestamp;
          // Convertir el Timestamp a DateTime
          DateTime savedDateTime = savedTimestamp.toDate();
          // Calcular el tiempo transcurrido
          Duration difference = DateTime.now().difference(savedDateTime);
          int differenceInSeconds = difference.inSeconds;
          int remainingSeconds = differenceInSeconds.remainder(60);

          _days = difference.inDays;
          _hours = difference.inHours;
          _minutes = difference.inMinutes.remainder(60);
          _seconds = remainingSeconds;
          _tiempoTotal = (_hours*60)+_minutes;

          setState(() {
            _elapsedTime =
                '${_hours} horas, ${_minutes} minutos y ${_seconds} segundos';
          });
        }
      }
    } catch (error) {
      print("Error al obtener la hora guardada: $error");
    }
  }


  Future<int?> obtenerUltimoTiempoDeAdiccion(String adiccion) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bitacoras')
        .where('adiccion', isEqualTo: adiccion)
        .orderBy('fecha', descending: true) 
        .limit(1) 
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si se encontraron documentos, devuelve el tiempo del primer documento (que será el más reciente)
      return querySnapshot.docs.first['tiempo'] as int;
    } else {
      // Si no se encontraron documentos, devuelve null
      return null;
    }
  } catch (error) {
    print('Error al obtener el último tiempo de la adicción: $error');
    return null;
  }
}
  //aqui termina

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
      body:SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 25),

              Container(
                margin: const EdgeInsets.only(left: 26),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Adicción',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Container(
                width: 343,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEDF2),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2, 
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                
                child: Theme(
                  data: ThemeData(
                    canvasColor: const Color(0xFFEFEDF2),
                  ),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedAdiccion,
                        hint: const Text(
                          'Seleccione una adicción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        items: adiccionesDisponibles.map((String adiccion) {
                          return DropdownMenuItem<String>(
                            value: adiccion,
                            child: Text(adiccion),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAdiccion = newValue;
                          });
                        },
                        dropdownColor: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(12.0),
                        
                      ),
                    ),
                  
                  // DropdownButtonFormField<String>(
                  //   decoration: const InputDecoration(
                  //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  //     border: InputBorder.none,
                  //   ),
                  //   items: adicciones.isNotEmpty
                  //       ? adicciones.map((adiccion) {
                  //           // Obtener el valor predefinido de la adicción
                  //           int? valor = valoresPredefinidos[adiccion];

                  //           return DropdownMenuItem(
                  //             value: valor != null ? valor.toString() : null,
                  //             child: Text(adiccion, style: TextStyle(fontSize: 16)),
                  //           );
                  //         }).toList()
                  //       : null,
                  //   onChanged: (value) {
                  //     if (value != null) {
                  //       // Convierte el valor de String a int
                  //       int valorSeleccionado = int.parse(value);

                  //       // Buscar la adicción basada en el valor seleccionado
                  //       String? adiccionSeleccionada;
                  //       valoresPredefinidos.forEach((key, val) {
                  //         if (val == valorSeleccionado) {
                  //           adiccionSeleccionada = key;
                  //         }
                  //       });

                  //       if (adiccionSeleccionada != null) {
                  //         print('Adicción seleccionada: $adiccionSeleccionada');
                  //         print('Valor seleccionado: $valorSeleccionado');
                  //       }

                  //     }
                  //   },
                  //   hint: const Text(
                  //     'Selecciona una opción',
                  //     style: TextStyle(
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                  )
                ),
              ),

              // if (selectedAdiccion != null)
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 14.0),
              //   child: Text(
              //     '${selectedAdiccion!}: ${elapsedHours[selectedAdiccion!]} + ${elapsedMinutes[selectedAdiccion!]} + ${elapsedSeconds[selectedAdiccion!]}',
              //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              //   ),
              // ),
            

              const SizedBox(height: 22),
              
              Container(
                width: 343,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(217, 136, 225, 219),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color.fromARGB(255, 6, 166, 153), width: 0.5),
                ),
                child: const Column(
                  children: [
                    Row( 
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.0, top:20),
                          child: Icon(Icons.message_outlined, color: Colors.black54), 
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 24.0, 20.0, 8.0),
                          child: Text(
                            " Como te sientes hoy con esa adicción?",
                            style: TextStyle(
                              color: Color.fromARGB(171, 0, 0, 0),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 30, top: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 12,),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedColor = Colors.yellow;
                          selectedButton = 'Muy bien';
                        });
                      },
                      icon: const Icon(Icons.sentiment_satisfied_alt, color: Color.fromARGB(255, 1, 212, 8),),
                      label: const Text(
                        'Muy bien',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: selectedColor == Colors.yellow ? Colors.grey[350] : Colors.white,
                        foregroundColor: const Color.fromARGB(255, 38, 176, 167),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedColor = Colors.blue;
                          selectedButton = 'Normal   ';
                        });
                      },
                      icon: const Icon(Icons.sentiment_neutral, color: Colors.blue),
                      label: const Text(
                        'Normal   ',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: selectedColor == Colors.blue ? Colors.grey[350] : Colors.white,
                        foregroundColor: const Color.fromARGB(255, 38, 176, 167),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedColor = Colors.red;
                          selectedButton = 'Mal   ';
                        });
                      },
                      icon: const Icon(Icons.sentiment_dissatisfied, color: Colors.red),
                      label: const Text(
                        'Mal   ',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: selectedColor == Colors.red ? Colors.grey[350] : Colors.white,
                        foregroundColor: const Color.fromARGB(255, 38, 176, 167),
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
            
              Container(
                margin: const EdgeInsets.only(left: 26),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Mi progreso',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 343,
                          height: 108,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF30D5C8).withOpacity(0.85),
                                const Color(0xFF30D5C8).withOpacity(0.28),
                              ],
                            ),
                          ),
                          child:  
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Tiempo sin adicciones",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                          child: Text(
                                            "${elapsedHours[selectedAdiccion] ?? 0}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      
                                        const Text(
                                          " horas",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                          child: Text(
                                            "${elapsedMinutes[selectedAdiccion] ?? 0}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          " minutos",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                          child: Text(
                                            "${elapsedSeconds[selectedAdiccion] ?? 0}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          " segundos",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
if (selectedAdiccion != null)
  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('bitacoras')
        .where('adiccion', isEqualTo: selectedAdiccion) // Filtrar por la opción seleccionada
        .orderBy('fecha', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
        return CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      final data = snapshot.data!;
      final documents = data.docs;

      if (documents.isEmpty) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildContainer('${selectedAdiccion!} menos', '0', Icons.smoking_rooms_rounded, Colors.orange),
            const SizedBox(width: 11),
            _buildContainer('Dinero ahorrado', '\$0', Icons.attach_money, Color.fromARGB(255, 43, 151, 47)),
          ],
        );
      }

      final doc = documents.first;
      int cantidad = doc['cantidad'] as int;
      final tiempo = doc['tiempo'] as int;

      if (selectedAdiccion == 'Cigarrillo electrónico') {
        cantidad = cantidad ~/ 200; // División entera
        print('-----------------------------$cantidad');
      }

      final Map<String, String> adiccionTexts = {
        'Refresco': 'Litros',
        'Alcohol': 'Litros',
        'Cigarro': 'Cigarros',
        'Metanfetamina': 'Gramos', 
        'Marihuana': 'Gramos',
        'Cigarrillo electrónico': 'Vapes',
      };

      final relacion = (_tiempoTotal2 * cantidad) / tiempo;
      print("$_tiempoTotal2  $cantidad   $tiempo   $tiempo");

      double roundedRelacion = relacion.roundToDouble();
      if ((relacion - relacion.floor()) > 0.25) {
        roundedRelacion = relacion.ceilToDouble();
      } else if ((relacion - relacion.floor()) < -0.25) {
        roundedRelacion = relacion.floorToDouble();
      }

      double precio = roundedRelacion;

      if (selectedAdiccion == 'Cigarro') {
        precio *= 4;
      } else if (selectedAdiccion == 'Refresco') {
        precio *= 20;
      } else if (selectedAdiccion == 'Alcohol'){
        precio *= 38;
      } else if (selectedAdiccion == 'Marihuana'){
        precio *= 180;
      } else if (selectedAdiccion == 'Metanfetamina'){
        precio *= 210;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildContainer(' ${adiccionTexts[selectedAdiccion!]} menos', '$roundedRelacion', Icons.smoking_rooms_rounded, Colors.orange),
          const SizedBox(width: 11),
          _buildContainer('Dinero ahorrado', '\$${precio}', Icons.attach_money, Color.fromARGB(255, 43, 151, 47)),
        ],
      );
    },
  )
else
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildContainer('Cantidad menos', '0', Icons.smoking_rooms_rounded, Colors.orange),
      const SizedBox(width: 11),
      _buildContainer('Dinero ahorrado', '\$0', Icons.attach_money, Color.fromARGB(255, 43, 151, 47)),
    ],
  ),

const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Container(
                          width: 166,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF30D5C8).withOpacity(1.0),
                                const Color(0xFF30D5C8).withOpacity(0.4), 
                              ],
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(7.5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite, 
                                      size: 19, 
                                      color: Color.fromARGB(255, 213, 95, 95)
                                    ),
                                    SizedBox(width: 7), 
                                    Text(
                                      "Dias extra de vida",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "0",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 11),
                        Container(
                          width: 166,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF30D5C8).withOpacity(1.0), 
                                const Color(0xFF30D5C8).withOpacity(0.4), 
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(7.5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.mood_rounded,
                                      size: 21, 
                                      color: Colors.blue, 
                                    ),
                                    SizedBox(width: 7), 
                                    Text(
                                      "Dias sin adicción",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${elapsedDays[selectedAdiccion] ?? 0}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _saveTimeToFirebase() async {
    // Obtener la fecha y hora actual
    DateTime currentDateTime = DateTime.now();

    // Crear un objeto Timestamp a partir de la fecha y hora actual
    Timestamp timestamp = Timestamp.fromDate(currentDateTime);

    // Guardar el objeto Timestamp en Firebase
    await FirebaseFirestore.instance
        .collection('nueva_fecha')
        .doc('hora_guardada')
        .set({'fecha_hora': timestamp});

    // Actualizar el estado local para mostrar la fecha y hora guardada
    setState(() {
      _savedDateTime = currentDateTime;
    });
  }
}


Widget _buildContainer(String title, String value, IconData icon, Color iconColor) {
  return Container(
    width: 166,
    height: 80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF30D5C8).withOpacity(1.0),
          const Color(0xFF30D5C8).withOpacity(0.4),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
              SizedBox(width: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
