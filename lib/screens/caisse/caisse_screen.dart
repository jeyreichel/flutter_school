import 'package:caisse_tectille/screens/caisse/recette.dart';
import 'package:caisse_tectille/screens/caisse/vente.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu/items_menu.dart';
import 'commande/commande_screen.dart';


class CaisseScreen extends StatefulWidget {
  final String username;
  CaisseScreen({required this.username});
  @override
  _CaisseScreen createState() => _CaisseScreen();
}

class _CaisseScreen extends State<CaisseScreen> {
  List<String> _menuIcons = [
    'assets/assets/recette.png',
    'assets/assets/restaurant.png',
    'assets/assets/vente.png',
    'assets/assets/modules.png',
   // 'assets/assets/utilisateur.png',
  ];

  String _currentDate = '';
  String _currentTime = '';
  String _storeName = '';
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _getStoreName();
  }
  // Méthode pour récupérer le nom du magasin à partir du stockage
  void _getStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeName = prefs.getString('storeName') ?? ''; // Si le nom du magasin n'est pas enregistré, utilisez une chaîne vide
    });
  }

  // Fonction pour mettre à jour la date et l'heure actuelles
  void _updateDateTime() {
    setState(() {
      _currentDate = _getCurrentDate();
      _currentTime = _getCurrentTime();
    });
  }
  // Fonction pour obtenir la date actuelle sous forme de chaîne
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  // Fonction pour obtenir l'heure actuelle sous forme de chaîne
  String _getCurrentTime() {
    DateTime now = DateTime.now();
    String hour = '${now.hour}'.padLeft(2, '0');
    String minute = '${now.minute}'.padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          date: _currentDate,
          time: _currentTime,
          storeName: _storeName,
          username: widget.username,
          backgroundColor: Colors.black45
          ,
        ),
        body: Row(
          children: [
            // Partie du menu
            Container(
              color: Colors.black54,
              width: 100, // Largeur du menu
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: ListView.separated(
                  itemBuilder: (context, index) => _buildMenuButtons()[index],
                  separatorBuilder: (context, index) => Column(
                    children: [
                      //_buildMenuButtons()[index],
                      SizedBox(height: 10),
                      // Divider(
                      //   color: Colors.white, // Couleur du diviseur
                      //   height: 1,
                      // ),
                      // SizedBox(height: 12),
                    ],
                  ),

                  itemCount: _menuIcons.length,
                ),
              ),
            ),
            Expanded(
              flex: 3, // Use 3/4 of the available space for content
              child: Container(
                color: Colors.black54,
                child: _buildContent(), // Display the current content here
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getMenuText(int index) {
    switch (index) {
      case 0:
        return 'Recette';
      case 1:
        return 'Commande';
      case 2:
        return 'Vente';
      case 3:
        return 'Modules';

      default:
        return '';
    }
  }

  // Fonction pour créer les boutons du menu à partir de la liste des icônes
  List<Widget> _buildMenuButtons() {
    return List.generate(
      _menuIcons.length,
          (index) => ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: _selectedIndex == index ? Color(0xFF23c1ff) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Colors.black54,
                width: 1.0,
              ),
            ),
            minimumSize: Size(25, 90)
        ),
        child: Column(
          children: [
            Image.asset(
              _menuIcons[index],
              width: 30,
              height: 30,
              color: _selectedIndex == index ? Colors.white : Colors.white,
            ),
            SizedBox(height: 6),
            Text(
              _getMenuText(index),
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return RecettePage();
      case 1:
        return CommandePage();
      case 2:
        return VentePage();
      case 3:
        return ItemsMenu();
      default:
        return Container();
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String date;
  final String time;
  final String storeName;
  final Color backgroundColor;

  CustomAppBar({
    required this.username,
    required this.date,
    required this.time,
    required this.storeName,
    required this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text(
            storeName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.5,
            ),
          ),

          Spacer(),
          Text('CAISSE', style: TextStyle(color: Colors.white, fontSize: 16)),
          Spacer(),
        ],
      ),      // Row(
      //   children: [
      //     Spacer(), // Ajoutez un Spacer pour déplacer le titre vers la droite
      //     Text('Caisse', style: TextStyle(color: Colors.white, fontSize: 16)),
      //     Spacer(),
      //   ],
      // ),
      backgroundColor: backgroundColor,
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.access_time,
              size: 25,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              date,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 4),
            Text(
              time,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 20),
            // GestureDetector(
            //   onTap: () {
            //     // Ajoutez ici le code à exécuter lorsque l'icône "person" est cliquée
            //   },
            //   child: Icon(
            //     Icons.person,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
