import 'package:caisse_tectille/screens/menu/items_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isPasswordObscured = true;
  String _keyboardInput = '';
  bool _isEmailFieldActive = true;
  bool isKeyboardVisible = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;
  bool _isEmailIncorrect = false;
  bool _isPasswordIncorrect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  void _addToKeyboardInput(String value) {
    if (_isEmailFieldActive) {
      if (_emailController.text.length < 50) {
        setState(() {
          _emailController.text += value;
        });
      }
    } else {
      if (_passwordController.text.length < 50) {
        setState(() {
          _passwordController.text += value;
        });
      }
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bool newIsKeyboardVisible = WidgetsBinding.instance!.window.viewInsets.bottom > 0;
    if (isKeyboardVisible != newIsKeyboardVisible) {
      setState(() {
        isKeyboardVisible = newIsKeyboardVisible;
      });
    }
    super.didChangeMetrics();
  }

  Widget _buildKeyboard() {
    final List<List<String>> keyboardLayout = [
      ['@', '.', ':', "'", '"', '-', '!', '?', '_', '&'],
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M'],
      ['N', 'Z', 'X', 'C', 'V', 'B'],
    ];

    double buttonSize = 55.0;

    return Column(
      children: keyboardLayout.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return GestureDetector(
              onTap: () => _addToKeyboardInput(key),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        _buildLoginForm(),
      ],),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(13.0),
                    child: Column(
                      children: [
                        Text('PAGE DE CONNEXION',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                        SizedBox(height: 10.0),
                        _buildTextFieldWithLabel('Email', Icons.email, _emailController, _isEmailEmpty, _isEmailIncorrect),
                        SizedBox(height: 10.0),
                        _buildTextFieldWithLabel('Mot de passe', Icons.password, _passwordController, _isPasswordEmpty, _isPasswordIncorrect),
                        SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: _onLoginButtonPressed,
                          child: Text('CONNECTER'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.black45,
                            minimumSize: Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //SizedBox(height: 3.0),
              Container(
                width: 700,
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(13.0),
                    child: _buildKeyboard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
      String label, IconData icon, TextEditingController controller, bool isEmpty, bool isIncorrect) {
    bool isPasswordField = label == 'Mot de passe';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          onTap: () {
            setState(() {
              _isEmailFieldActive = !isPasswordField;
            });
          },
          obscureText: isPasswordField && _isPasswordObscured,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40,
              minHeight: 24,
            ),
            suffixIcon: isPasswordField
                ? IconButton(
              icon: _isPasswordObscured ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured; // Toggle the visibility state
                });
              },
            )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
          ),
        ),
        if (isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text('Ce champ ne peut pas être vide', style: TextStyle(color: Colors.red)),
          ),
        if (isIncorrect)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text('L\'email ou le mot de passe est incorrect', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Future<void> _onLoginButtonPressed() async {
    setState(() {
      _isEmailEmpty = _emailController.text.isEmpty;
      _isPasswordEmpty = _passwordController.text.isEmpty;
      _isEmailIncorrect = false;
      _isPasswordIncorrect = false;
    });

    if (_isEmailEmpty || _isPasswordEmpty) {
      return;
    }

    String email = _emailController.text.toLowerCase();
    String password = _passwordController.text.toLowerCase();

    try {
      // Access the 'users' collection in Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Check if a user with the entered email and password exists
      QuerySnapshot<Object?> querySnapshot = await users
          .where('email', isEqualTo: email)
          .where('paswword', isEqualTo: password)
          .get();

      if (querySnapshot.size > 0) {
        String loggedInUserId = querySnapshot.docs[0].id;
        String role = querySnapshot.docs[0]['role'];
        DateTime now = DateTime.now();
        String dateTimeString = now.toString();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInUserId',loggedInUserId);
        await prefs.setString('loginDateTime', dateTimeString);
        await prefs.setString('roleUser', role);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemsMenu()),
        );

      }
      else {
        // No user found with the entered email and password
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //title: Text('Erreur'),
              content: Text('Aucun utilisateur trouvé avec ces identifiants.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Erreur lors de la vérification des identifiants : $e');
    }
  }
}
