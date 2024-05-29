// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freeyourself_app/helper/helper_function.dart';
import 'package:freeyourself_app/main.dart';
import 'package:freeyourself_app/pages/auth/login_page.dart';
import 'package:freeyourself_app/pages/profile_page.dart';
import 'package:freeyourself_app/pages/search_page.dart';
import 'package:freeyourself_app/service/auth_service.dart';
import 'package:freeyourself_app/service/database_service.dart';
import 'package:freeyourself_app/widgets/group_tile.dart';
import 'package:freeyourself_app/widgets/widgets.dart';

class HomeGroups extends StatefulWidget {
  const HomeGroups({Key? key}) : super(key: key);

  @override
  State<HomeGroups> createState() => _HomeGroupsState();
}

class _HomeGroupsState extends State<HomeGroups> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

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
        actions: [
          IconButton(onPressed: () {
            nextScreenReplace(context, SearchPage());
          }, 
          icon: Icon(
            Icons.search,
            color: Colors.teal.shade900,
            size: 30,
            )),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 142, 217, 203),
        title: Text(
          "Grupos",
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
    
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 142, 217, 203),
        child: Icon(
          Icons.add, 
          color: Colors.teal.shade900,
          size: 30,
        ),
      ),
    );
  }


  popUpDialog(BuildContext context){
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context){
        return StatefulBuilder(
          builder: ((context, setState){
          return AlertDialog(
            title: Text(
              "Crear un grupo",
              textAlign: TextAlign.left,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true 
                ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.teal.shade900), 
                ): TextField(
                  onChanged: (val) {
                    setState(() {
                      groupName = val;
                    });
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 142, 217, 203),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
          
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
          
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 142, 217, 203),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
                child: Text("Cancelar"),
              ),
          
              ElevatedButton(
                onPressed: () async{
                  if (groupName != ""){
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .createGroup(userName,
                            FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                    showSnackbar(
                      context, Colors.green, "Grupo creado exitosamente."
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 142, 217, 203),
                ),
                child: Text("Crear"),
              ),
            ],
          );
        }));
      }
    );
  }


  groupList(){
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null){
            if(snapshot.data['groups'].length != 0){
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                    groupId: getId(snapshot.data['groups'][reverseIndex]),
                    groupName:  getName(snapshot.data['groups'][reverseIndex]), 
                    userName: snapshot.data['fullName']);
                },
              );
            }else{
              return noGroupWidget();
            }
          }else{
            return noGroupWidget();
          }
        }
        else{
          return Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 142, 217, 203),
            ),
          );
        }
      },
    );
  }


  noGroupWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap:() {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle, 
              color: Colors.grey.shade500,
              size: 75,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "No te has unido a ningún grupo, dale click en el botón o busca con ayuda del botón de navegación.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}


