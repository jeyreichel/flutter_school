import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginIdPage extends StatefulWidget {
  final String loggedInUserId;

  LoginIdPage({required this.loggedInUserId});

  @override
  _LoginIdPage createState() => _LoginIdPage();
}


class _LoginIdPage extends State<LoginIdPage> {
  String _identifiant = '';
  String storedIdentifier = '';
  @override
  void initState() {
    super.initState();
    getStoredIdentifier(); // Retrieve stored identifier when the page initializes
  }

  Future<void> getStoredIdentifier() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedIdentifier = prefs.getString('userIdentifier') ?? '';
    });
  }
  void _appendToIdentifiant(String value) {
    setState(() {
      _identifiant += value;
    });
  }

  void _clearIdentifiant() {
    setState(() {
      _identifiant = '';
    });
  }

  Future<void> _submitIdentifiant() async {
    int enteredId = int.tryParse(_identifiant) ?? 0;
    print('enteredId $enteredId');
    print('_identifiant $_identifiant');

    if (_identifiant.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Alert',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            content: Text(
              'Veuillez saisir un identifiant.',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearIdentifiant();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
    else  {
      // Log pour vérifier que la requête Firestore est correcte
      print('Requête Firestore : identifier = $enteredId');

      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Check if a user with the entered email and password exists
      QuerySnapshot<Object?> querySnapshot = await users
          .where('identifiant', isEqualTo: enteredId)
          .get();

      print('Nombre de résultats : ${querySnapshot.size}');
      print('Données trouvées : ${querySnapshot.docs}');
      print('enteredId $enteredId');
      if (querySnapshot.size > 0) {
        // Identifier matches, show success message
        print('Identifier correct, login successful!');
        // You can navigate to another page or show a success message here
      }
      else {
        // Identifier does not match or doesn't exist
        print('Identifier incorrect, login failed!');
        // You can show an alert or error message here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Authentification'),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: Center(
        child: Container(
          width: 320,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: TextEditingController(text: _identifiant),
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                        child: Image.asset(
                          'assets/assets/sidentifier.png', // Replace with your image path
                          width: 10, // Adjust the width of the image
                          height: 18, // Adjust the height of the image
                        ),
                      ),
                      labelText: 'Identifiant',
                      hintText: 'Saisissez votre identifiant ici',
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54), // Change border color to black54
                      ),
                      labelStyle: TextStyle(color: Colors.black54), // Change label text color to black54
                    ),
                  ),
                  SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNumberButton('1'),
                      _buildNumberButton('2'),
                      _buildNumberButton('3'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNumberButton('4'),
                      _buildNumberButton('5'),
                      _buildNumberButton('6'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNumberButton('7'),
                      _buildNumberButton('8'),
                      _buildNumberButton('9'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _clearIdentifiant,
                        icon: Icon(Icons.backspace, color: Colors.white),
                        label: Text(''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      _buildNumberButton('0'),
                      ElevatedButton.icon(
                        onPressed: () async {
                          _submitIdentifiant();
                        },
                        icon: Icon(Icons.login, color: Colors.white),
                        label: Text(''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String value) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: TextButton(
        onPressed: () => _appendToIdentifiant(value),
        child: Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.black54,
        ),
      ),
    );
  }
}
