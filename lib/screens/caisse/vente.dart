import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class VentePage extends StatefulWidget {
  @override
  _VentePageState createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> {
  String _searchID = '';
  double _totalAmount = 0.0;
  String userName = '';
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 250,
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher par ID Commande',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchID = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('commandes')
                        .where('status', isEqualTo: 'payé')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {

                      if (snapshot.hasError) {
                        return Text('Erreur : ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      _totalAmount = 0.0;
                      List<DataRow> dataRows = snapshot.data!.docs.map((document) {
                        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                        int id = data?['idCommande'] ?? 0;
                        String idUser = data?['idUser'] ?? '';
                        double total = data?['totalTTC'] ?? 0.0;
                        _totalAmount += total;
                        String date = DateFormat('yyyy-MM-dd HH:mm')
                            .format((data?['date'] as Timestamp).toDate());

                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return snapshot.data!.docs.indexOf(document) % 2 == 0
                                ? Colors.white
                                : Colors.black12;
                          }),
                          cells: [
                            DataCell(Text(id.toString())),
                            DataCell(Text('${total.toString()} DT')),
                            DataCell(Text(date)),
                            DataCell(Text(idUser)),
                          ],
                          onLongPress: () {
                            // Afficher une alerte avec les détails de la commande
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Articles de la commande #$id'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total : ${total.toString()} DT'),
                                      SizedBox(height: 8.0),
                                      Text('Date : $date'),
                                      SizedBox(height: 8.0),
                                      Text('Utilisateur : $idUser'),
                                      SizedBox(height: 8.0),
                                      // Afficher les articles ici
                                      Text('Articles :'),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: (data?['articles'] as List<dynamic>).map((article) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Designation : ${article['designation']}'),
                                              Text('Prix : ${article['prix']} DT'),
                                              Text('Quantite : ${article['quantite']}'),
                                              SizedBox(height: 8.0),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Fermer'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }).toList();
                      isLoading = false;

                      return DataTable(
                        columnSpacing: 80.0,
                        dataRowHeight: 40.0,
                        headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color(0xFF067487)),
                        headingTextStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        dividerThickness: 1.0,
                        columns: [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Utilisateur')),
                        ],
                        rows: dataRows,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Totale:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    '${_totalAmount.toStringAsFixed(3)} DT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
