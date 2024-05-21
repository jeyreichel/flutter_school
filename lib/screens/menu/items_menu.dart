import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/entrer_stock.dart';
import '../articles/article_screen.dart';
import '../caisse/caisse_screen.dart';
import '../logn/login.dart';
import '../parametres/parametres_screen.dart';
import '../rapport/rapport_screen.dart';
import '../stock/stock_screen.dart';

class ItemsMenu extends StatefulWidget {
  @override
  ItemsMenuState createState() => ItemsMenuState();
}

class ItemsMenuState extends State<ItemsMenu> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    fromStorage();
  }

  Future<void> fromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Role = prefs.getString('roleUser') ?? '';
    setState(() {
      userRole = Role;
      print('userRole $userRole');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 500,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) =>
                        _buildButton(index, context, userRole!),
                  ),
                ),
                TextButton(
                  onPressed: () async {
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
                        fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(int index, BuildContext context, String userRole) {
    String imagePath;
    String label;
    VoidCallback onPressed;

    if (userRole == 'admin' || userRole == 'gérant') {
      switch (index) {
        case 0:
          imagePath = 'assets/assets/caisse.png';
          label = 'Caisse';
          onPressed = () => _onButton1Pressed(context);
          break;
        case 1:
          imagePath = 'assets/assets/liste.png';
          label = 'Articles';
          onPressed = () => _onButton2Pressed(context);
          break;
        case 2:
          imagePath = 'assets/assets/rapport-dactivite.png';
          label = 'Rapport';
          onPressed = () => _onButton3Pressed(context);
          break;
        case 3:
          imagePath = 'assets/assets/chariot.png';
          label = 'Stock';
          onPressed = () => _onButton4Pressed(context);
          break;
        case 4:
          imagePath = 'assets/assets/parametre.png';
          label = 'Paramètres';
          onPressed = () => _onButton5Pressed(context);
          break;
        default:
          imagePath = '';
          label = '';
          onPressed = () {};
      }
    } else {
      switch (index) {
        case 0:
          imagePath = 'assets/assets/caisse.png';
          label = 'Caisse';
          onPressed = () => _onButton1Pressed(context);
          break;
        case 1:
          imagePath = 'assets/assets/liste.png';
          label = 'Articles';
          onPressed = () => _onButton2Pressed(context);
          break;
        case 2:
          imagePath = 'assets/assets/rapport-dactivite.png';
          label = 'Rapport';
          onPressed = () => _onButton3Pressed(context);
          break;
        default:
          imagePath = '';
          label = '';
          onPressed = () {};
      }
    }

    // Vérifier si l'image et le label sont vides, et si c'est le cas, retourner un SizedBox.shrink()
    if (imagePath.isEmpty && label.isEmpty) {
      return SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.all(5),
        backgroundColor: Colors.grey[300],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath.isNotEmpty)
            Image.asset(
              imagePath,
              width: 50,
              height: 55,
            ),
          SizedBox(height: 4),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }

  void _onButton1Pressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CaisseScreen(
                username: '',
              )),
    );
  }

  void _onButton2Pressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArticleScreen(
                username: '',
              )),
    );
  }

  void _onButton3Pressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockEntryReportPage()),
    );
  }

  void _onButton4Pressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StockScreen(
                username: '',
              )),
    );
  }

  void _onButton5Pressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingScreen(
                username: '',
              )),
    );
  }
}
