// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/profile_page.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class Recursos extends StatefulWidget {
  final String videoId = 'DPHXWWw5RM4'; 
  final String secondVideoId = '7wJvkIautCk';

  const Recursos({super.key});

  @override
  State<Recursos> createState() => _RecursosState();
}

class _RecursosState extends State<Recursos> {
  late YoutubePlayerController _controller;
  late YoutubePlayerController _secondController;
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

@override
  void initState() {
    gettingUserData();
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    )..addListener(_onPlayerStateChange);

    _secondController = YoutubePlayerController(
    initialVideoId: widget.secondVideoId,
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
    )..addListener(_onSecondPlayerStateChange);

    fetchNews().then((articles) {
      setState(() {
        newsArticles = articles;
      });
    });
  }

  void _onPlayerStateChange() {
    if (_controller.value.playerState == PlayerState.playing) {
      // Puedes hacer algo cuando el video esté reproduciéndose aquí
    }
  }

  void _onSecondPlayerStateChange() {
    if (_secondController.value.playerState == PlayerState.playing) {
    // Puedes hacer algo cuando el segundo video esté reproduciéndose aquí
    }
  }

  List<dynamic> newsArticles = [];

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse(
        'https://gnews.io/api/v4/search?q=Conciencia%20drogas&lang=es&country=mx&max=10&apikey=38df3e6b1395edd3762902d2a49ab682'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }

  void launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $urlString';
    }
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
          "Recursos",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
              color: Color.fromARGB(255, 118, 213, 203), 
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Adicción",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.justify,
                    "La adicción es una pérdida del control caracterizada por la práctica compulsiva de la conducta, en donde hay daño o deterioro de la calidad de vida de la persona debido a las consecuencias negativas de la práctica de la conducta adictiva.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Color del texto
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
              Text(
                textAlign: TextAlign.justify,
                "Las adicciones son clasificadas en dos grupos: trastornos por consumo de sustancias y trastornos inducidos por sustancias. Estas son enfermedades mentales, en las cuales se ve afectado el sistema de recompensa cerebral y se llega a modificar la conducta de la persona.",
                style: TextStyle(
                  fontSize: 16,
                ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0), 
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: YoutubePlayer(controller: _controller),
                ),
              ),
            ),
            SizedBox(height: 20),
              Text(
                "Síntomas de las Adicciones",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.teal.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                textAlign: TextAlign.justify,
                "Ansiedad, irritabilidad, compulsión por consumir la sustancia, inquietud, deterioro en diferentes áreas de la vida, negación ante la adicción. A continuación proporcionamos a detalle material sobre la neurociencia de las adicciones.",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              //aqui agregar otro video diferente
              Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0), 
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: YoutubePlayer(controller: _secondController),
                ),
              ),
            ),
              SizedBox(height: 20),
              Text(
                "Preguntas Frecuentes",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.teal.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
               SizedBox(height: 10),
              // Preguntas frecuentes y respuestas...
              FAQItem(
                question: "¿Qué factores influyen en una persona para desarrollar una adicción?",
                answer: "Influye el ámbito social en el que se desenvuelve la persona, si tiene una enferemedad mental, su capacidad para manejar las situaciones estresantes, la tolerancia a la frustración, los niveles de estrés que maneje en su vida, frecuencia y uso de las sustancias, entre otros.",
              ),
              FAQItem(
                question: "¿Qué desencadena el deseo de consumir una sustancia o repetir el comportamiento adictivo?",
                answer: "Usualmente suele haber una reincidencia en el consumo de las sustancias porque, dependiendo de la sutancia o adicción, tienen ciertos efectos placenteros o satisfactorios y lo que busca es volver a sentir ese bienestar que brinda el consumir o realizar esa adicción.",
              ),
              FAQItem(
                question: "¿Qué obstáculos podrían surgir en el camino hacia la recuperación?",
                answer: "El enfrentarse a escenarios en la vida en donde se conviva con personas que consuman la sustancia que se esta tratando de dejar, el extrañar la satisfacción o bienestar que daba el consumir o realizar la adicción.",
              ),
              FAQItem(
                question: "¿Cómo puede la familia y amigos ayudar a una persona con una adicción?",
                answer: "Una buena forma de ayudar es preguntar “como te puedo ayudar”, esto nos ayuda a entender de que forma quiere ser ayudada la persona en lugar de nosotros suponer automáticamente. Si la persona esta envuelta en una adicción que niega y además esta consumiendo su vida, lo recomendado es intentar hablar con la persona sobre un internamiento o comenzar terapia psiquiátrica y psicológica.",
              ),
              SizedBox(height: 20),
              if (newsArticles.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  "Noticias sobre Adicciones",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.teal.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: newsArticles.length,
                  itemBuilder: (context, index) {
                    final article = newsArticles[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          final url = article['url'];
                          if (url != null) {
                            launchURL(url);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              article['image'] != null
                                  ? Image.network(
                                      article['image'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(height: 8),
                              Text(
                                article['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                article['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey.shade200,
        child: Text(
          "La información proporcionada es solo para fines informativos. Se recomienda consultar a un especialista para un tratamiento y orientación más específicos y personalizados.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}


class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    required this.question,
    required this.answer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            textAlign: TextAlign.justify,
            answer,
            style: TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}