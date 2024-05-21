import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';

class EditUserPage extends StatefulWidget {
  final UserService userService;
  final User user;
  final Function() onUserUpdated;

  EditUserPage({required this.userService, required this.user, required this.onUserUpdated});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs avec les informations de l'utilisateur actuel
    _nomController.text = widget.user.nom;
    _prenomController.text = widget.user.prenom;
    _roleController.text = widget.user.role;
    _emailController.text = widget.user.email ?? '';
    _passwordController.text = widget.user.password;
    _idController.text = widget.user.id.toString();
  }

  void _updateUser() {
    // Mettez à jour les informations de l'utilisateur avec les valeurs des contrôleurs
    String nom = _nomController.text;
    String prenom = _prenomController.text;
    String role = _roleController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    int id = int.tryParse(_idController.text) ?? 0;

    User updatedUser = User(
      id: id,
      nom: nom,
      prenom: prenom,
      role: role,
      email: email,
      password: password,
    );

    widget.userService.updateUser(updatedUser);
    widget.onUserUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier l\'utilisateur'),
        backgroundColor: Colors.black45,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Rôle'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: _updateUser,
              child: Text('Mettre à jour', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
