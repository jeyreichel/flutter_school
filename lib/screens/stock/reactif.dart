import 'package:caisse_tectille/models/entrer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../services/article_service.dart';
import '../../../models/article.dart';
import '../../models/entrer_stock.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  String selectedDesignation = '';
  String selectedFournisseur = '';
  ArticleService _articleService = ArticleService();
  TextEditingController prixController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  List<DataRow> dataRows = [];
  DateTime selectedDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  String pdfFilePath = '';
  int pdfCounter = 1;
  TextEditingController searchBarController = TextEditingController();
  List<List<String>> cellTexts = [];
  List<DataRow> dataRowsBackup = [];
  List<DataRow> newDataRows = [];
  List<String> filteredDesignations = [];
  bool articleExists = false;
  Map<String, TextEditingController> stockControllers = {};
  Map<String, TextEditingController> priceControllers = {};
  bool isListVisible = true;
  List<StockItem> entresStock = [];
  late List<StockItem> _originalStock;

  void initState() {
    super.initState();
    _filteredStock = List.from(_originalStock);
    _articleService = ArticleService();
    List<String> distinctDesignations = getDistinctDesignations();
    if (distinctDesignations.isNotEmpty) {
      selectedDesignation = distinctDesignations[0];
    }

    for (var designation in getDistinctDesignations()) {
      stockControllers[designation] = TextEditingController();
      priceControllers[designation] = TextEditingController();
    }
  }

  late List<StockItem> _filteredStock;
  void updateStockAndPrice(String designation, int newStock, double newPrice) {
    setState(() {
      final index = dataRows.indexWhere(
          (row) => (row.cells[0].child as Text).data! == designation);

      if (index >= 0) {
        // Update the stock and price in the specific DataRow
        final row = dataRows[index];
        row.cells[1] = DataCell(Text(newStock.toString()));
        row.cells[2] = DataCell(Text(newPrice.toString()));
      }
    });
  }

  DataRow buildDataRow(int index, DataRow row) {
    final color = index.isEven ? Colors.white : Colors.black12;
    final designation = (row.cells[0].child as Text).data!;
    final stock = int.tryParse((row.cells[1].child as Text).data!) ?? 0;
    final price = double.tryParse((row.cells[2].child as Text).data!) ?? 0.0;

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: [
        ...row.cells, // Existing cells
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  dataRows.removeAt(index);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final stockController =
                        TextEditingController(text: stock.toString());
                    final priceController =
                        TextEditingController(text: price.toString());

                    return AlertDialog(
                      title: Text('Modifier le stock et le prix'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Stock'),
                          ),
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Prix'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            int newStock =
                                int.tryParse(stockController.text ?? '') ?? 0;
                            double newPrice =
                                double.tryParse(priceController.text ?? '') ??
                                    0.0;

                            updateStockAndPrice(
                                designation, newStock, newPrice);
                            Navigator.of(context).pop();
                          },
                          child: Text('Enregistrer'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        )),
      ],
    );
  }

  Future<void> generateAndSavePDF() async {
    final pdf = pdfWidgets.Document();

    final titleStyle = pdfWidgets.TextStyle(
      fontSize: 24,
      fontWeight: pdfWidgets.FontWeight.bold,
      //alignment: pdfWidgets.Alignment.center,
    );

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.center,
              children: [
                pdfWidgets.Text("Entrée stock", style: titleStyle),
                pdfWidgets.SizedBox(height: 20), // Add some spacing

                pdfWidgets.Table(
                  border: pdfWidgets.TableBorder.all(),
                  defaultVerticalAlignment:
                      pdfWidgets.TableCellVerticalAlignment.middle,
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        for (var header in [
                          "Désignation",
                          "Stock",
                          "Prix",
                          "Fournisseur",
                          "Date"
                        ])
                          pdfWidgets.Container(
                            padding: const pdfWidgets.EdgeInsets.all(8),
                            child: pdfWidgets.Text(header,
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                      ],
                    ),
                    for (var rowText in cellTexts)
                      pdfWidgets.TableRow(
                        children: [
                          for (var cellText in rowText)
                            pdfWidgets.Container(
                              padding: const pdfWidgets.EdgeInsets.all(8),
                              child: pdfWidgets.Text(cellText),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final tempDir = await getDownloadsDirectory();
    final tempPath = path.join(tempDir!.path,
        'stock_entrer_$pdfCounter.pdf'); // Append the counter value
    final File file = File(tempPath);
    await file.writeAsBytes(await pdf.save());
    pdfFilePath = tempPath;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF enregistré avec succès."),
        backgroundColor: Colors.green,
      ),
    );
    pdfCounter++; // Increment the counter
    //await OpenFile.open(pdfFilePath);
  }

  void performSearch() {
    String searchValue =
        searchController.text.toLowerCase(); // Convert to lowercase
    List<String> designations = getDistinctDesignations()
        .map((designation) =>
            designation.toLowerCase()) // Convert list to lowercase
        .toList();

    if (designations.contains(searchValue)) {
      setState(() {
        selectedDesignation = getDistinctDesignations()[
            designations.indexOf(searchValue)]; // Retrieve the original casing
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Désignation introuvable."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void performSearchAppBar() {
    String searchValueAppBar = searchBarController.text.toLowerCase();
    List<String> designations = getDistinctDesignations()
        .map((designation) => designation.toLowerCase())
        .toList();

    if (designations.contains(searchValueAppBar)) {
      bool articleExists = dataRows.any((row) =>
          (row.cells[0].child as Text).data!.toLowerCase() ==
          searchBarController.text.toLowerCase());

      if (articleExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("L'article existe déjà dans la liste."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          selectedDesignation = getDistinctDesignations()[
              designations.indexOf(searchValueAppBar)];
          updateDataTable(selectedDesignation);
          searchBarController.clear();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Désignation introuvable."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateDataTable(String selectedDesignation) {
    List<Article> articles = _articleService.getArticles();
    Article selectedArticle = articles
        .firstWhere((article) => article.designation == selectedDesignation);

    newDataRows.insert(
        0,
        DataRow(cells: [
          DataCell(Text(selectedArticle.designation)),
          DataCell(Text(selectedArticle.stock.toString())),
          DataCell(Text(selectedArticle.prix.toString())),
          DataCell(Text(DateFormat('dd-MM-yyyy').format(selectedDate))),
        ]));

    setState(() {
      dataRows.clear();
      dataRows.addAll(newDataRows);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void filterData(String searchValue) {
    setState(() {
      dataRows = dataRowsBackup.where((row) {
        return row.cells.any((cell) =>
            cell.child is Text &&
            (cell.child as Text)
                .data!
                .toLowerCase()
                .contains(searchValue.toLowerCase()));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          // Wrap the content in a Row
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: !isListVisible,
              child: Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // Use Row to place input and button side by side
                        children: [
                          Expanded(
                            child: Container(
                              width:
                                  150, // Make the input take the available width
                              child: TextField(
                                controller: searchBarController,
                                // onChanged: (value) {
                                //   filterData(value);
                                // },
                                decoration: InputDecoration(
                                  labelText: 'Rechercher par désignation',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: 8), // Add spacing between input and button
                          Container(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4eb5ec),
                                minimumSize: Size(100, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                      color: Color(0xFF4eb5ec), width: 1.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                              ),
                              onPressed: () async {
                                performSearchAppBar();
                              },
                              icon: Icon(Icons.search,
                                  color: Colors.white, size: 20),
                              label: Text('Recherche',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isListVisible,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4eb5ec),
                  minimumSize: Size(120, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(color: Color(0xFF4eb5ec), width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                onPressed: () async {
                  if (dataRows.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Aucune entrée à générer en PDF."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    List<List<String>> cellTexts = [];
                    for (var row in dataRows) {
                      List<String> rowTexts = [];
                      for (var cell in row.cells) {
                        if (cell.child is Text) {
                          rowTexts.add((cell.child as Text).data!);
                        }
                      }
                      cellTexts.add(rowTexts);
                    }
                    final pdf = pdfWidgets.Document();

                    final titleStyle = pdfWidgets.TextStyle(
                      fontSize: 24,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    );

                    pdf.addPage(
                      pdfWidgets.Page(
                        build: (context) {
                          return pdfWidgets.Center(
                            child: pdfWidgets.Column(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Text("Entrée stock",
                                    style: titleStyle),
                                pdfWidgets.SizedBox(height: 20),
                                pdfWidgets.Table(
                                  border: pdfWidgets.TableBorder.all(),
                                  defaultVerticalAlignment: pdfWidgets
                                      .TableCellVerticalAlignment.middle,
                                  children: [
                                    pdfWidgets.TableRow(
                                      children: [
                                        for (var header in [
                                          "Désignation",
                                          "Stock",
                                          "Prix",
                                          "Fournisseur",
                                          "Date"
                                        ])
                                          pdfWidgets.Container(
                                            padding:
                                                const pdfWidgets.EdgeInsets.all(
                                                    8),
                                            child: pdfWidgets.Text(header,
                                                style: pdfWidgets.TextStyle(
                                                    fontWeight: pdfWidgets
                                                        .FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                    for (var rowText in cellTexts)
                                      pdfWidgets.TableRow(
                                        children: [
                                          for (var cellText in rowText)
                                            pdfWidgets.Container(
                                              padding: const pdfWidgets
                                                  .EdgeInsets.all(8),
                                              child: pdfWidgets.Text(cellText),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                    final tempDir = await getDownloadsDirectory();
                    final tempPath = path.join(
                        tempDir!.path, 'stock_entrer_$pdfCounter.pdf');
                    final File file = File(tempPath);
                    await file.writeAsBytes(await pdf.save());
                    pdfFilePath = tempPath;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("PDF enregistré avec succès."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    pdfCounter++;
                  }
                },
                icon: Icon(Icons.picture_as_pdf_outlined,
                    color: Colors.white, size: 20),
                label:
                    Text('Imprimer PDF', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isListVisible = !isListVisible;
                });
              },
              icon: Icon(
                isListVisible ? Icons.add : Icons.list,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                isListVisible ? 'Nouvelle entrée ' : 'Bons entrés',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFb67823),
                minimumSize: Size(120, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: Color(0xFFb67823), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
            )
            // ElevatedButton.icon(
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.pink,
            //     minimumSize: Size(120, 48),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(5.0),
            //       side: BorderSide(color: Colors.pink, width: 1.0),
            //     ),
            //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            //   ),
            //   onPressed: () async
            //   {
            //     if (dataRows.isEmpty) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text("Aucune entrée à générer en PDF."),
            //           backgroundColor: Colors.red,
            //         ),
            //       );
            //     } else {
            //       List<List<String>> cellTexts = [];
            //       for (var row in dataRows) {
            //         List<String> rowTexts = [];
            //         for (var cell in row.cells) {
            //           if (cell.child is Text) {
            //             rowTexts.add((cell.child as Text).data!);
            //           }
            //         }
            //         cellTexts.add(rowTexts);
            //       }
            //       final pdf = pdfWidgets.Document();
            //
            //       final titleStyle = pdfWidgets.TextStyle(
            //         fontSize: 24,
            //         fontWeight: pdfWidgets.FontWeight.bold,
            //       );
            //
            //       pdf.addPage(
            //         pdfWidgets.Page(
            //           build: (context) {
            //             return pdfWidgets.Center(
            //               child: pdfWidgets.Column(
            //                 mainAxisAlignment: pdfWidgets.MainAxisAlignment.center,
            //                 children: [
            //                   pdfWidgets.Text("Entrée stock", style: titleStyle),
            //                   pdfWidgets.SizedBox(height: 20),
            //                   pdfWidgets.Table(
            //                     border: pdfWidgets.TableBorder.all(),
            //                     defaultVerticalAlignment: pdfWidgets.TableCellVerticalAlignment.middle,
            //                     children: [
            //                       pdfWidgets.TableRow(
            //                         children: [
            //                           for (var header in ["Désignation", "Stock", "Prix", "Fournisseur", "Date"])
            //                             pdfWidgets.Container(
            //                               padding: const pdfWidgets.EdgeInsets.all(8),
            //                               child: pdfWidgets.Text(header, style: pdfWidgets.TextStyle(fontWeight: pdfWidgets.FontWeight.bold)),
            //                             ),
            //                         ],
            //                       ),
            //                       for (var rowText in cellTexts)
            //                         pdfWidgets.TableRow(
            //                           children: [
            //                             for (var cellText in rowText)
            //                               pdfWidgets.Container(
            //                                 padding: const pdfWidgets.EdgeInsets.all(8),
            //                                 child: pdfWidgets.Text(cellText),
            //                               ),
            //                           ],
            //                         ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             );
            //           },
            //         ),
            //       );
            //
            //       final tempDir = await getDownloadsDirectory();
            //       final tempPath = path.join(tempDir!.path, 'stock_entrer_$pdfCounter.pdf');
            //       final File file = File(tempPath);
            //       await file.writeAsBytes(await pdf.save());
            //       pdfFilePath = tempPath;
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text("PDF enregistré avec succès."),
            //           backgroundColor: Colors.green,
            //         ),
            //       );
            //       pdfCounter++;
            //     }
            //   },
            //   icon: Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
            //   label: Text('Générer et télécharger le PDF', style: TextStyle(color: Colors.white)),
            // ),
            // SizedBox(width: 10,),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: !isListVisible
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Nouvelle entrée",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    //color: Color(0xFFE4E8FF),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align content to the left
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          width: 180,
                          height: 44, // Adjust the width as needed
                          child: TextField(
                            controller: searchController,
                            onSubmitted: (_) => performSearch(),
                            decoration: InputDecoration(
                              labelText: 'Rechercher désignation',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: performSearch,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          constraints: BoxConstraints(maxHeight: 44),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: prixController,
                            decoration: InputDecoration(
                              labelText: 'Prix',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              // Gérer les modifications de l'entrée "Prix"
                            },
                          ),
                        ),
                        Container(
                          width: 180,
                          constraints: BoxConstraints(maxHeight: 44),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              // Gérer les modifications de l'entrée "Stock"
                            },
                          ),
                        ),
                        Container(
                          height: 44,
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.black38),
                                SizedBox(width: 8),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      selectedDate), // Format the date as you want
                                  style: TextStyle(color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (selectedDate == null ||
                                searchController.text.isEmpty ||
                                selectedFournisseur.isEmpty ||
                                prixController.text.isEmpty ||
                                stockController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Veuillez remplir tous les champs."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              if (dataRows.any((row) =>
                                  (row.cells[0].child as Text)
                                      .data!
                                      .toLowerCase() ==
                                  selectedDesignation.toLowerCase())) {
                                searchController.clear();
                                prixController.clear();
                                stockController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "L'article existe déjà dans la liste."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                // Tous les champs sont remplis et l'article n'existe pas dans la liste, ajouter la ligne
                                dataRows.add(DataRow(cells: [
                                  DataCell(Text(selectedDesignation)),
                                  DataCell(Text(stockController.text)),
                                  DataCell(Text(prixController.text)),
                                  DataCell(Text(selectedFournisseur)),
                                  DataCell(Text(DateFormat('dd-MM-yyyy')
                                      .format(selectedDate))),
                                ]));
                                searchController.clear();
                                prixController.clear();
                                stockController.clear();
                                setState(() {});
                              }
                            }
                          },
                          icon: Icon(Icons.add, color: Colors.white, size: 20),
                          label: Text('Ajouter',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF19cfbe),
                            minimumSize: Size(90, 49),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(
                                  color: Color(0xFF19cfbe), width: 1.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: dataRows.isNotEmpty
                          ? DataTable(
                              columnSpacing: 130.0,
                              dataRowHeight: 45.0,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color(0xFF19cfbe),
                              ),
                              headingTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              dividerThickness: 1.0,
                              columns: [
                                DataColumn(label: Text('Désignation')),
                                DataColumn(label: Text('Stock')),
                                DataColumn(label: Text('Prix')),
                                DataColumn(label: Text('Fournisseur')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: dataRows.asMap().entries.map((entry) {
                                final index = entry.key;
                                final row = entry.value;

                                return buildDataRow(index, row);
                              }).toList(),
                            )
                          : Center(
                              child: Text(
                                "Aucune entrée",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.black54),
                              ),
                            ),
                    ),
                  )
                ],
              )
            : Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Bons des entrés stock",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 130.0,
                            dataRowHeight: 45.0,
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color(0xFF19cfbe),
                            ),
                            headingTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            dividerThickness: 1.0,
                            columns: [
                              //DataColumn(label: Text('')),
                              DataColumn(label: Text('Réference')),
                              DataColumn(label: Text('Fournisseur')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Nbr articles')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Articles')),
                            ],
                            rows: _filteredStock.asMap().entries.map((stock) {
                              final int index = stock.key;
                              final StockItem stockk = stock.value;

                              return DataRow(
                                color: MaterialStateColor.resolveWith((states) {
                                  return index % 2 == 0
                                      ? Colors.white
                                      : Colors.black12;
                                }),
                                cells: [
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.list,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          )),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  List<String> getDistinctDesignations() {
    return _articleService
        .getArticles()
        .map((article) => article.designation)
        .toSet()
        .toList();
  }
}
