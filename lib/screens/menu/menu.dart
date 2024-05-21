import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final String username; // Propriété pour stocker le nom d'utilisateur

  MenuPage({required this.username});
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Liste des icônes pour le menu
  List<IconData> _menuIcons = [
    Icons.menu,
    // Icons.settings,
    //  Icons.mail,
    // Icons.person,
  ];
  List<IconData> _menuDetailIcons = [
    Icons.check_box_outline_blank,
    Icons.list,
    Icons.stacked_bar_chart_rounded,
    Icons.add_shopping_cart,
    Icons.settings,
  ];
  List<String> _menuDetailTitles = [
    'Caisse',
    'Articles',
    'Rapport',
    'Stock',
    'Paramètres',
  ];
  String _currentDate = '';
  String _currentTime = '';
  String _userRole = 'Rôle inconnu';
  // Index de l'icône actuellement sélectionné
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  // Fonction pour mettre à jour la date et l'heure actuelles
  void _updateDateTime() {
    setState(() {
      _currentDate = _getCurrentDate();
      _currentTime = _getCurrentTime();
      _userRole =
          'Admin'; // Remplacez cette valeur par le rôle de l'utilisateur authentifié
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
      title: 'Menu Flutter Desktop',
      home: Scaffold(
        appBar: CustomAppBar(
          date: _currentDate,
          time: _currentTime,
          username: widget.username,
          backgroundColor: Colors.black54,
        ),
        body: Row(
          children: [
            // Partie du menu
            Container(
              color: Colors.black54,
              width: 100, // Largeur du menu
              child: Padding(
                padding: EdgeInsets.only(top: 30), // Espacement du haut du menu
                child: ListView.separated(
                  itemBuilder: (context, index) => _buildMenuButtons()[index],
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 10), // Espacement entre les boutons
                  itemCount: _menuIcons.length,
                ),
              ),
            ),
            // Partie du contenu
            Expanded(
              child: Container(
                color: Colors.white,
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Nombre de colonnes dans le GridView
                    crossAxisSpacing:
                        10, // Espacement horizontal entre les éléments
                    mainAxisSpacing:
                        10, // Espacement vertical entre les éléments
                  ),
                  itemCount: _menuDetailIcons
                      .length, // Utilisez la longueur de _menuDetailIcons
                  itemBuilder: (context, index) => _buildMenuItemCard(index),
                ),
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
        return 'Menu';
      case 1:
        return 'Paramètres';
      case 2:
        return 'Profil';
      default:
        return '';
    }
  }

  // Fonction pour créer les boutons du menu à partir de la liste des icônes
  List<Widget> _buildMenuButtons() {
    return List.generate(
      _menuIcons.length,
      (index) => GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          children: [
            Icon(
              _menuIcons[index],
              color: _selectedIndex == index ? Colors.white : Colors.black,
            ),
            SizedBox(height: 4), // Espacement entre l'icône et le texte
            Text(
              _getMenuText(index),
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(int index) {
    return Card(
      color: Colors.grey[200],
      child: GestureDetector(
        onTap: () {
          // Ajoutez ici le code à exécuter lorsque l'icône est cliquée
          switch (index) {
            case 0:
              // Code à exécuter lorsque la première icône est cliquée
              print('00000');
              break;
            case 1:
              // Code à exécuter lorsque la deuxième icône est cliquée
              print('11111');
              break;
            case 2:
              // Code à exécuter lorsque la troisième icône est cliquée
              print('2222');
              break;
            case 3:
              // Code à exécuter lorsque la troisième icône est cliquée
              print('3333');
              break;
            case 4:
              // Code à exécuter lorsque la troisième icône est cliquée
              print('44444');
              break;
            // Ajoutez plus de cas pour les autres icônes
            default:
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _menuDetailIcons[index],
              size: 40,
              color: Colors.black,
            ),
            SizedBox(height: 8),
            Text(
              _menuDetailTitles[index],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String date;
  final String time;
  final Color backgroundColor;

  CustomAppBar({
    required this.username,
    required this.date,
    required this.time,
    required this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Text(
              username, // Display the username here
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 16),
            Text(
              date,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(
                width: 4), // Add the desired empty space between date and time
            Text(
              time,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Ajoutez ici le code à exécuter lorsque l'icône "settings" est cliquée
              },
              child: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Ajoutez ici le code à exécuter lorsque l'icône "person" est cliquée
              },
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
