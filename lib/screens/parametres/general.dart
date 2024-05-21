import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralPage extends StatefulWidget {
  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  TextEditingController _storeNameController = TextEditingController();
  bool stockAutorise = true;
  @override
  void initState() {
    super.initState();
    _loadStockAuthorization();
  }

  // Méthode pour charger la valeur de StockAutorise depuis le stockage
  void _loadStockAuthorization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stockAutorise = prefs.getBool('StockAutorise') ?? true;
    });
  }

  // Méthode pour enregistrer la valeur de StockAutorise dans le stockage
  void _saveStockAuthorization(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('StockAutorise', value);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  void _saveStoreName() async {
    String storeName = _storeNameController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storeName', storeName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nom du magasin enregistré avec succès!'),
      ),
    );
    print('naaaaaaaaaaaaaame ${prefs.getString('storeName')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Paramètres')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.6, // Réduire la largeur
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: Text(
                      'Générale',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: TextField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du magasin',
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveStoreName();
                        },
                        child: Text('ENREGISTRER'),
                      )),
                  SizedBox(height: 8), // Ajuster l'espacement vertical
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: Text(
                      'Article', // Titre du groupe de paramètres
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Stock de valeur par défaut')),
                        DataColumn(label: Text('Unité valeur par défaut')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(DropdownButton<String>(
                            items: <String>[
                              'Désactivé',
                              'Activé',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              // Gérer le changement d'option ici
                            },
                          )),
                          DataCell(DropdownButton<String>(
                            items: <String>[
                              'Pièce',
                              'Non',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              // Gérer le changement d'option ici
                            },
                          )),
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 8), // Ajuster l'espacement vertical
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: Text(
                      'Panier de caisse', // Titre du groupe de paramètres
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Prix d\'article modifiable')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Switch(value: true, onChanged: (value) {})),
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: Text(
                      'Stock',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 3.0), // Ajuster l'espacement vertical
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Stock négatif autorisé')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(
                            Switch(
                              value: stockAutorise,
                              onChanged: (value) {
                                setState(() {
                                  stockAutorise = value;
                                  _saveStockAuthorization(value);
                                });
                              },
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
