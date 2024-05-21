import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/recette.dart';
import '../../services/recette_service.dart';

class RecettePage extends StatefulWidget {
  @override
  _RecettePageState createState() => _RecettePageState();
}

class _RecettePageState extends State<RecettePage> {
  final RecetteService _recetteService = RecetteService();
  late List<Recette> recettes;
  late List<Recette> _filteredRecettes;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchIdCaisse = '';

  @override
  void initState() {
    super.initState();

    // Initialize locale data for date formatting
    initializeDateFormatting();

    recettes = _recetteService.getRecettes();
    _filteredRecettes = List.from(recettes);
  }
  void _resetSearch() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filteredRecettes = List.from(recettes);
    });
  }
  void _onSearchCaisseChanged(String value) {
    _filterRecettes(); // Appeler la fonction de filtre après avoir mis à jour _searchCaisse
  }

  void _filterRecettes() {
    if (_startDate == null && _endDate == null) {
      _filteredRecettes = List.from(recettes);
      return;
    }    _filteredRecettes = recettes.where((recette) {
      if (_startDate != null && _endDate != null) {
        return recette.date.year >= _startDate!.year &&
            recette.date.month >= _startDate!.month &&
            recette.date.day >= _startDate!.day &&
            recette.date.year <= _endDate!.year &&
            recette.date.month <= _endDate!.month &&
            recette.date.day <= _endDate!.day;
      } else if (_startDate != null) {
        return recette.date.year >= _startDate!.year &&
            recette.date.month >= _startDate!.month &&
            recette.date.day >= _startDate!.day;
      } else {
        return recette.date.year <= _endDate!.year &&
            recette.date.month <= _endDate!.month &&
            recette.date.day <= _endDate!.day;
      }
    }).toList();
  }
  void _showDatePicker(String dateType) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        print("Selected Date: $selectedDate"); // Add this line for debugging

        if (dateType == 'date1') {
          _startDate = selectedDate;
        } else if (dateType == 'date2') {
          _endDate = selectedDate;
        }

        _filterRecettes(); // Call the filtering method
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchIdCaisse = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Recherche par Caisse',
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showDatePicker('date1');
              },
              icon: Icon(Icons.date_range, color: Colors.black38, size: 20),
              label: Text(
                _startDate != null ? DateFormat('dd/MM/yyyy').format(
                    _startDate!) : 'Date Debut',
                style: TextStyle(color: Colors.black38),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black38, minimumSize: Size(100, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(
                    color:  Colors.black38,
                    width: 1.0,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showDatePicker('date2');
              },
              icon: Icon(Icons.date_range, color: Colors.black38, size: 20),
              label: Text(
                _endDate != null
                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                    : 'Date Fin',
                style: TextStyle(color: Colors.black38),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black38, minimumSize: Size(100, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(
                    color:  Colors.black38,
                    width: 1.0,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                _resetSearch();
              },
              icon: Icon(Icons.restart_alt, color: Colors.white, size: 20),
              label: Text('Rest',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4eb5ec), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(
                    color:  Color(0xFF4eb5ec),
                    width: 1.0,
                  ),
                ),
                backgroundColor: Color(0xFF4eb5ec),
                minimumSize: Size(100, 48),
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
                stream: FirebaseFirestore.instance
                    .collection('caisses')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var filteredArticles = snapshot.data!.docs.where((caisse) {
                    var data = caisse.data() as Map<String, dynamic>;
                    String IdCaisse = data['loggedInUserId']?.toLowerCase() ?? '';
                    return IdCaisse.contains(_searchIdCaisse) ;
                  }).toList();
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 100.0,
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Date de fermeture')),
                        DataColumn(label: Text("Date d'ouverture")),
                        DataColumn(label: Text('Utilisateur')),
                      ],
                      rows:filteredArticles.map((QueryDocumentSnapshot document) {
                        Map<String, dynamic>? data =
                        document.data() as Map<String, dynamic>?;
                        int IdCaisse = data!['IdCaisse'] ?? '';
                        String loggedInUserId = data!['loggedInUserId'] ?? '';
                        String dateFrm = DateFormat('yyyy-MM-dd HH:mm')
                            .format((data?['date_close_caisse'] as Timestamp).toDate());
                        DateTime? loginDateTime;
                        if (data?['loginDateTime'] is Timestamp) {
                          loginDateTime = (data?['loginDateTime'] as Timestamp).toDate();
                        } else if (data?['loginDateTime'] is String) {
                          loginDateTime = DateTime.tryParse(data?['loginDateTime']);
                        }
                        String dateOvr = loginDateTime != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(loginDateTime)
                            : 'N/A';
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return snapshot.data!.docs.indexOf(document) %
                                2 ==
                                0
                                ? Colors.white
                                : Colors.black12;
                          }),
                          cells: [
                            DataCell(Text(IdCaisse.toString())),
                            DataCell(Text(dateOvr)),
                            DataCell(Text(dateFrm)),
                            DataCell(Text(loggedInUserId)),
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
