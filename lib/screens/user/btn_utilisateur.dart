import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../logn/login.dart';
import '../logn/login_identifant.dart';

class LogoutPage extends StatelessWidget {
  LogoutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(

          color: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 300,
            height: 200,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   'Êtes-vous sûr(e) de vouloir vous déconnecter ?',
                //   style: TextStyle(fontSize: 18),
                // ),
                // SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Color(0xFF23c1ff),
                //     padding: EdgeInsets.all(16.0),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(6.0),
                //       side: BorderSide(color: Colors.black12, width: 1.0),
                //     ),
                //     minimumSize: Size(275,52),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Icon(Icons.login_outlined, color: Colors.white),
                //       SizedBox(width: 8),
                //       Text("Déconnecter"),
                //     ],
                //   ),
                // ),
                SizedBox(height: 20,),
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('roleUser');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Quitter l'application",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
