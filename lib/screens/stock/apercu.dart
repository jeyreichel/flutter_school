import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApercuPage extends StatefulWidget {
  @override
  _ApercuPage createState() => _ApercuPage();
}

class _ApercuPage extends State<ApercuPage> {
  TextEditingController _searchTextController = TextEditingController();
  String _searchReference = '';
  String _searchDesignation = '';
  bool stockAutoriseValue = true;

  @override
  void initState() {
    super.initState();
    _fetchStockAutorise();
  }

  Future<void> _fetchStockAutorise() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? stockAutorise = prefs.getBool('StockAutorise');
      if (stockAutorise != null) {
        setState(() {
          stockAutoriseValue = stockAutorise;
        });
      }

      // Une fois que vous avez récupéré la valeur de StockAutorise, appelez le setState pour reconstruire l'interface utilisateur avec la nouvelle valeur stockAutoriseValue.
    } catch (e) {
      print('Error fetching StockAutorise from SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 250,
                height: 48,
                child: TextField(
                  controller: _searchTextController,
                  decoration: InputDecoration(
                    labelText: 'Recherche',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchReference = value.toLowerCase();
                      // Mettez à jour d'autres filtres selon votre besoin
                    });
                  },
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                label: Text('Exporter', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF067487),
                  minimumSize: Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(color: Color(0xFF067487), width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.5, horizontal: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('articles').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var filteredArticles = snapshot.data!.docs.where((article) {
                    var data = article.data() as Map<String, dynamic>;

                    String reference = data['reference']?.toLowerCase() ?? '';
                    String designation = data['designation']?.toLowerCase() ?? '';
                    bool stockPositive = int.parse(data['stock'] ?? '0') > 0;
                    return reference.contains(_searchReference) &&
                        designation.contains(_searchDesignation) &&
                        (stockAutoriseValue || stockPositive);
                  }).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 120.0,
                      dataRowHeight: 50.0,
                      headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Color(0xFF067487),
                      ),
                      headingTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dividerThickness: 1.0,
                      columns: [
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Référence')),
                        DataColumn(label: Text('Catégorie')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Prix')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Image')),
                      ],
                      rows: filteredArticles.map((QueryDocumentSnapshot document) {
                        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                        String codeAbarre = data!['code a barre'] ?? '';
                        String name = data['designation'] ?? '';
                        String categorie = data['categorie'] ?? '';
                        String reference = data['reference'] ?? '';
                        String prix = data['prix'] ?? '';
                        String stock = data['stock'] ?? '';
                        String imageUrl = data['image_url'] ?? '';
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return snapshot.data!.docs.indexOf(document) % 2 == 0
                                ? Colors.white
                                : Colors.grey.shade200; // Utilisez grey.shade200 pour obtenir un gris clair
                          }),
                          cells: [
                            DataCell(Text(codeAbarre)),
                            DataCell(Text(reference)),
                            DataCell(Text(categorie)),
                            DataCell(Text(name)),
                            DataCell(Text('$prix DT')),
                            DataCell(Text(stock)),
                            DataCell(
                              imageUrl.isNotEmpty ? Image.network(imageUrl) : Icon(Icons.error),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
