import 'package:caisse_tectille/screens/menu/items_menu.dart';
import 'package:caisse_tectille/screens/menu/menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AAIzaSyA5N2PCLTcCG0oqslcMIz59T4iSOfPNdP0',
      appId: '1:497767583121:android:43c0892cfaeca9e71dde30',
      messagingSenderId: '497767583121',
      projectId: 'caissetectille',
      storageBucket: 'caissetectille.appspot.com',
    ),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: true,
      home: ItemsMenu(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    return email != null && password != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
      routes: {
        '/menu': (context) => MenuPage(
              username: '',
            ),
      }, // Remplacez MyHomePage par LoginPage
    );
  }
}
