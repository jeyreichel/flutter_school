import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _isNomEmpty = false;
  bool _isPrenomEmpty = false;
  bool _isRoleEmpty = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;
  bool _isIdEmpty = false;
  late UserService _userService;
  bool _isEmailInvalid = false;
  String? _selectedRole;
  @override
  void initState() {
    super.initState();
  }

  Future<void> addUser(String nom, String prenom, String? role, String email,
      String paswword, String identifiant) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      DocumentReference docRef = await users.add({
        'nom': nom,
        'prenom': prenom,
        'role': role,
        'email': email,
        'paswword': paswword,
        'identifiant': identifiant,
      });

      await docRef.update({'id': docRef.id});

      print('user ajoutée avec succès !');
    } catch (e) {
      print('Erreur lors de l\'ajout de la user : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AJOUTER NOUVEAU UTILISATEUR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        //iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.black45,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Aligner les éléments en haut
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Aligner les éléments à gauche
                                  children: [
                                    TextField(
                                      controller: _nomController,
                                      decoration: InputDecoration(
                                        labelText: 'Nom',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                    if (_isNomEmpty)
                                      Text('Ce champ ne peut pas être vide',
                                          style: TextStyle(color: Colors.red)),
                                    SizedBox(height: 15),
                                    TextField(
                                      controller: _prenomController,
                                      decoration: InputDecoration(
                                        labelText: 'Prenom',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                    if (_isPrenomEmpty)
                                      Text('Ce champ ne peut pas être vide',
                                          style: TextStyle(color: Colors.red)),
                                    SizedBox(height: 15),
                                    DropdownButtonFormField<String>(
                                      value: _selectedRole,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'serveur(se)',
                                          child: Text('Serveur(se)'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'gérant',
                                          child: Text('Gérant'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'admin',
                                          child: Text('Admin'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRole = value!;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Role',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Veuillez sélectionner un rôle';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_isRoleEmpty)
                                      Text('Veuillez sélectionner un rôle',
                                          style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 20), // Espacement entre les colonnes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Aligner les éléments à gauche
                                  children: [
                                    TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                    if (_isEmailEmpty)
                                      Text('Ce champ ne peut pas être vide',
                                          style: TextStyle(color: Colors.red)),
                                    if (_isEmailInvalid)
                                      Text('L\'adresse e-mail est invalide',
                                          style: TextStyle(color: Colors.red)),
                                    SizedBox(height: 15),
                                    TextField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                    if (_isPasswordEmpty)
                                      Text('Ce champ ne peut pas être vide',
                                          style: TextStyle(color: Colors.red)),
                                    SizedBox(height: 15),
                                    TextField(
                                      controller: _idController,
                                      decoration: InputDecoration(
                                        labelText: 'Identifiant',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                    if (_isIdEmpty)
                                      Text('Ce champ ne peut pas être vide',
                                          style: TextStyle(color: Colors.red)),
                                    SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isNomEmpty =
                                              _nomController.text.isEmpty;
                                          _isPrenomEmpty =
                                              _prenomController.text.isEmpty;
                                          _isEmailEmpty =
                                              _emailController.text.isEmpty;
                                          _isPasswordEmpty =
                                              _passwordController.text.isEmpty;
                                          _isIdEmpty =
                                              _idController.text.isEmpty;
                                          _isEmailInvalid = _emailController
                                                  .text.isNotEmpty &&
                                              !_emailController.text
                                                  .contains('@');
                                        });
                                        if (!_isNomEmpty &&
                                            !_isPrenomEmpty &&
                                            !_isPasswordEmpty &&
                                            !_isIdEmpty &&
                                            !_isEmailInvalid) {
                                          String nom = _nomController.text;
                                          String prenom =
                                              _prenomController.text;
                                          String? role = _selectedRole;
                                          String email = _emailController.text;
                                          String password =
                                              _passwordController.text;
                                          String id = _idController.text;
                                          addUser(nom, prenom, role, email,
                                              password, id);
                                          //widget.onUserAdded();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('AJOUTER',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        minimumSize: Size(350, 50),
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
