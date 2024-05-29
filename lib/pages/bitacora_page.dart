//SE AGREGARON COSAS DEL TIEMPO JOSUE
// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/home_page.dart';
import 'package:freeyourself_app/pages/profile_page.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Bitacora extends StatefulWidget {
  const Bitacora({Key? key}) : super(key: key);

  @override
  State<Bitacora> createState() => _BitacoraState();
}

//josue
class RespuestaAdiccion {
  String adiccion;
  int cantidad;
  int tiempo;
  String motivo;

  RespuestaAdiccion({required this.adiccion, required this.cantidad, required this.motivo, required this.tiempo});
}  
//termina josue

class _BitacoraState extends State<Bitacora> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

  //josue
  // DateTime? _savedDateTime;
  // String _elapsedTime = '0 horas y 0 minutos';
  //josue termina

  //josue
  final List<String> adicciones = [
    'Cigarro',
    'Alcohol',
    'Cigarrillo electrónico',
    'Marihuana',
    'Metanfetamina',
    'Refresco'
  ];
  
  
  void navigateToOtherPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HomePage(adiccionesSeleccionadas: adiccionesSeleccionadas.toList()),
    ),
  );
}

  late Timer _timer;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  late int _totalMinutes = 0;

  void startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      _seconds++;
      if (_seconds == 60) {
        _seconds = 0;
        _minutes++;
        _totalMinutes++;
        if (_minutes == 60) {
          _minutes = 0;
          _hours++;
          if (_hours == 24) {
            _hours = 0;
            _days++;
          }
        }
      }

    });
  });
}


  Set<String> adiccionesSeleccionadas = {};
  List<RespuestaAdiccion> respuestas = [];
  List<RespuestaAdiccion> respuestas2 = [];

  DateTime fechaActual = DateTime.now();
  String fechaFormateada = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final Map<String, List<String>> preguntasPorAdiccion = {
    'Cigarro': [
      '¿Cuántos cigarros fumaste hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ],
    'Alcohol': [
      '¿Cuántos litros de bebidas alcohólicas consumiste hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ],
    'Cigarrillo electrónico': [
      '¿Cuántas veces usaste el cigarrillo electrónico hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ],
    'Marihuana': [
      '¿Cuántos gramos de marihuana consumiste hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ],
    'Metanfetamina': [
      '¿Cuántas dosis (en gramos) de metanfetamina consumiste hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ],
    'Refresco': [
      '¿Cuántos litros de refresco consumiste hoy?',
      '¿Porque motivos realizaste esta acción?',
      '¿Cada cuanto tiempo(min) realizaste ésta acción?',
    ]
  };

  //josue
  Map<String, TextEditingController> respuestasController = {};
  Map<String, TextEditingController> respuestasController2 = {};
  Map<String, String?> dropdownValues = {};
  Map<String, String> elapsedTimes = {};
  Map<String, String> elapsedHours = {};
  Map<String, String> elapsedMinutes = {};
  Map<String, String> elapsedSeconds = {};
  List<String> adiccionesDisponibles = [];
  String? selectedAdiccion;

  @override
  void initState() {
    super.initState();
    for (var adiccion in adicciones) {
      respuestasController[adiccion] = TextEditingController();
      respuestasController2[adiccion] = TextEditingController();
      dropdownValues[adiccion] = null;
      // elapsedTimes[adiccion] = 'No hay registros';
      // elapsedHours[adiccion] = 'No hay registros';
      // elapsedMinutes[adiccion] = 'No hay registros';
      // elapsedSeconds[adiccion] = 'No hay registros';
    }
    startTimer();
    _fetchElapsedTimeForEachAdiccion();
    _fetchAvailableAdicciones();
    gettingUserData();
  }

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
          
          _seconds = remainingSeconds;

          setState(() {
            elapsedTimes[adiccion] =
                'Tiempo que ha pasado: ${remainingHours} horas, ${remainingMinutes} minutos y ${_seconds} segundos';
            elapsedHours[adiccion] =
                'Horas: ${remainingHours}';
            elapsedMinutes[adiccion] =
                'Minutos: ${remainingMinutes}';
            elapsedSeconds[adiccion] =
                'Segundos: ${remainingSeconds}';
          });
        }
      }
    } catch (error) {
      print("Error al obtener el tiempo transcurrido: $error");
    }
  }

  void stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    _timer.cancel(); 
    for (var controller in respuestasController.values) {
      controller.dispose();
    }
    super.dispose();
  }
  //termina josue





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



  //josue
  // Future<void> _calculateElapsedTime() async {
  //   try {
  //     // Consultar la hora guardada en la base de datos
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('nueva_fecha')
  //         .doc('hora_guardada')
  //         .get();

  //     // Verificar si el documento existe y contiene datos
  //     if (snapshot.exists && snapshot.data() != null) {
  //       // Obtener el mapa de datos del documento
  //       Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

  //       // Verificar si el campo 'fecha_hora' existe y no es nulo
  //       if (data.containsKey('fecha_hora') && data['fecha_hora'] != null) {
  //         // Obtener la fecha y hora guardada como un objeto Timestamp
  //         Timestamp savedTimestamp = data['fecha_hora'] as Timestamp;
  //         // Convertir el Timestamp a DateTime
  //         DateTime savedDateTime = savedTimestamp.toDate();
  //         // Calcular el tiempo transcurrido
  //         Duration difference = DateTime.now().difference(savedDateTime);
  //         int differenceInSeconds = difference.inSeconds;
  //         int remainingSeconds = differenceInSeconds.remainder(60);
  //         // Actualizar el estado para mostrar el tiempo transcurrido en la pantalla
  //         setState(() {
  //           _elapsedTime =
  //               '${difference.inHours} horas, ${difference.inMinutes.remainder(60)} minutos y $remainingSeconds segundos';
  //         });
  //       }
  //     }
  //   } catch (error) {
  //     print("Error al obtener la hora guardada: $error");
  //   }
  // }  

  // @override
  // void dispose() {
  //   for (var controller in respuestasController.values) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }
  //termina josue



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 142, 217, 203),
        title: Text(
          "Bitácora",
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
      body:SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                      color: const Color.fromARGB(255, 6, 166, 153), width: 0.4),
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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
                      title: Text(
                        adiccion,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      ...preguntasPorAdiccion[adiccion]!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pregunta = entry.value;

                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(83, 48, 213, 199),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      pregunta,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFEDF2),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: TextField(
                                    controller: respuestasController[adiccion],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Ingrese su respuesta',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 18.0, vertical: 11),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (index == 1) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(83, 48, 213, 199),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      pregunta,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  height: 40, // Ajusta el tamaño del campo de texto según sea necesario
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFEDF2),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: dropdownValues[adiccion],
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(15.0,2.0, 10.0, 8.0),
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Estrés',
                                        child: Text('Estrés', style:TextStyle(fontSize: 15)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Enojo',
                                        child: Text('Enojo', style:TextStyle(fontSize: 15)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Tristeza',
                                        child: Text('Tristeza',style:TextStyle(fontSize: 15)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Ansiedad',
                                        child: Text('Ansiedad',style:TextStyle(fontSize: 15)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Felicidad',
                                        child: Text('Felicidad',style:TextStyle(fontSize: 15)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Otra',
                                        child: Text('Otra',style:TextStyle(fontSize: 15)),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        dropdownValues[adiccion] = value;
                                      });
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
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(83, 48, 213, 199),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      pregunta,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Container(
                                  width: 320,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFEDF2),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: TextField(
                                    controller: respuestasController2[adiccion],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Ingrese su respuesta',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 18.0, vertical: 11),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }).toList(),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Iterar sobre las adicciones seleccionadas
                    for (var adiccion in adiccionesSeleccionadas) {
                      // Obtener la cantidad, el motivo y el tiempo
                      final cantidad = int.tryParse(respuestasController[adiccion]?.text ?? '0') ?? 0;
                      final motivo = dropdownValues[adiccion] ?? '';
                      final tiempo = int.tryParse(respuestasController2[adiccion]?.text ?? '0') ?? 0;

                      // Crear una instancia de RespuestaAdiccion
                      final respuesta = RespuestaAdiccion(
                        adiccion: adiccion,
                        cantidad: cantidad,
                        tiempo: tiempo,
                        motivo: motivo,
                      );

                      // Agregar la respuesta a la lista de respuestas
                      respuestas.add(respuesta);

                      // Guardar la respuesta en Firestore
                      await FirebaseFirestore.instance.collection('bitacoras').add({
                        'adiccion': respuesta.adiccion,
                        'cantidad': respuesta.cantidad,
                        'motivo': respuesta.motivo,
                        'tiempo': respuesta.tiempo,
                        'fecha': Timestamp.now(),
                      });
                    }

                    // Actualizar los tiempos transcurridos para cada adicción
                    await _fetchElapsedTimeForEachAdiccion();

                    // Mostrar un SnackBar para indicar que se guardaron las respuestas
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromARGB(255, 41, 186, 174),
                        content: Text('Respuestas guardadas'),
                      ),
                    );

                    // Limpiar la lista de respuestas después de guardarlas
                    respuestas.clear();

                    // Actualizar la interfaz
                    setState(() {
                      adiccionesSeleccionadas.clear(); // Deseleccionar todas las adicciones
  respuestasController.forEach((key, controller) => controller.clear()); // Limpiar los campos de texto
  respuestasController2.forEach((key, controller) => controller.clear()); // Limpiar los campos de texto
  dropdownValues.clear(); // Limpiar los valores seleccionados en el DropdownButton
                    });
                  } catch (error) {
                    print("Error al guardar los datos: $error");
                    // Mostrar un SnackBar en caso de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Error al guardar los datos'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFF30D5C8)),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 14.0),
            //   child: DropdownButton<String>(
            //     isExpanded: true,
            //     value: selectedAdiccion,
            //     hint: const Text(
            //       'Seleccione una adicción',
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     items: adiccionesDisponibles.map((String adiccion) {
            //       return DropdownMenuItem<String>(
            //         value: adiccion,
            //         child: Text(adiccion),
            //       );
            //     }).toList(),
            //     onChanged: (String? newValue) {
            //       setState(() {
            //         selectedAdiccion = newValue;
            //       });
            //     },
            //   ),
            // ),
            

            // if (selectedAdiccion != null)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 14.0),
            //     child: Text(
            //       '${selectedAdiccion!}: ${elapsedHours[selectedAdiccion!]} + ${elapsedMinutes[selectedAdiccion!]} + ${elapsedSeconds[selectedAdiccion!]}',
            //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //     ),
            //   ),
            // SizedBox(height: 50,),
             

            const SizedBox(height: 20),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: adicciones.map((adiccion) {
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 8.0),
            //       child: Text(
            //         '${adiccion}: ${elapsedTimes[adiccion]}',
            //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //       ),
            //     );
            //   }).toList(),
            // ),
            // SizedBox(height: 50,),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Historial'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Primera tabla
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('bitacoras').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          // Crear un mapa para almacenar los documentos más recientes agrupados por fecha y adicción
                          Map<String, Map<String, DocumentSnapshot>> groupedDocuments = {};

                          // Obtener los documentos y agruparlos por fecha y adicción
                          final data = snapshot.data!;
                          final documents = data.docs;
                          documents.forEach((doc) {
                            final fecha = (doc['fecha'] as Timestamp).toDate();
                            final formattedDate = DateFormat('dd/MM/yyyy').format(fecha);
                            final adiccion = doc['adiccion'];

                            // Verificar si ya hay un registro de esta adicción para esta fecha
                            if (!groupedDocuments.containsKey(formattedDate) || 
                                !groupedDocuments[formattedDate]!.containsKey(adiccion)) {
                              // Si no hay un registro de esta adicción para esta fecha, se agrega este documento
                              groupedDocuments.putIfAbsent(formattedDate, () => {});
                              groupedDocuments[formattedDate]![adiccion] = doc;
                            } else {
                              // Si ya hay un registro de esta adicción para esta fecha, se compara con el nuevo documento
                              final existingDoc = groupedDocuments[formattedDate]![adiccion]!;
                              final existingDate = (existingDoc['fecha'] as Timestamp).toDate();
                              if (fecha.isAfter(existingDate)) {
                                // Si el nuevo documento es más reciente, se reemplaza el registro existente
                                groupedDocuments[formattedDate]![adiccion] = doc;
                              }
                            }
                          });

                          // Construir la interfaz
                          return Container(
                            width: 400,
                            height: 600,
                            child: SingleChildScrollView(
                              child: Column(
                                children: groupedDocuments.entries.map((entry) {
                                  final fecha = entry.key;
                                  final registros = entry.value.values.toList();
                            
                                  // Construir la tabla para esta fecha
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Mostrar la fecha
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'Fecha: $fecha',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold, color: Color.fromARGB(255, 40, 182, 170)
                                          ),
                                        ),
                                      ),
                                      // Mostrar los registros de esta fecha
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: [
                                            DataColumn(label: Text('Adicción')),
                                            DataColumn(label: Text('Cantidad')),
                                            DataColumn(label: Text('Motivo')),
                                            DataColumn(label: Text('Tiempo'),),
                                          ],
                                          rows: registros.map((doc) {
                                            final adiccion = doc['adiccion'];
                                            final cantidad = doc['cantidad'];
                                            final motivo = doc['motivo'];
                                            final tiempo = doc['tiempo'];
                            
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(adiccion)),
                                                DataCell(Text('$cantidad')),
                                                DataCell(Text(motivo)),
                                                DataCell(Text('$tiempo')),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Color.fromARGB(218, 36, 163, 153),
                      ), ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Color.fromARGB(218, 6, 154, 142),
        child: const Icon(Icons.calendar_month, color: Colors.white),
      ),
    );
  }
}

