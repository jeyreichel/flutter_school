import 'package:caisse_tectille/models/entrer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:path/path.dart' as
path;
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/entrer_stock.dart';
import '../../../services/StockEntryReceipt.dart';
import '../../../services/article_service.dart';
import '../../../models/article.dart';
class SortiePage extends StatefulWidget {
  @override
  SortiePageState
  createState() => SortiePageState
    ();
}

class SortiePageState extends State<SortiePage> {
  String selectedDesignation = '';
  String selectedFournisseur = '';
  ArticleService _articleService = ArticleService();
  TextEditingController prixController = TextEditingController();
  TextEditingController _fournisseurController = TextEditingController();
  TextEditingController _totalController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController nbrArticlesController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController _searchTextController = TextEditingController();
  List<DataRow> dataRows = [];
  DateTime selectedDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  String pdfFilePath = '';
  int pdfCounter = 1;
  TextEditingController searchBarController = TextEditingController();
  List<List<String>> cellTexts = [];
  TextEditingController referenceController = TextEditingController();
  TextEditingController _searchTextArticleController = TextEditingController();
  List<DataRow> dataRowsBackup = [];
  List<DataRow> newDataRows = [];
  List<String> filteredDesignations = [];
  bool articleExists = false;
  Map<String, TextEditingController> stockControllers = {};
  Map<String, TextEditingController> priceControllers = {};
  bool isListVisible = true;
  List<StockItem> entresStock = [];
  late List<StockEntryReceipt> _originalStock;
  List<int> selectedIndices = [];
  List<Article> uniqueArticles = []; // Liste d'articles uniques
  final StockEntryReceiptService _stockItemService = StockEntryReceiptService();
  double total = 0.0;
  List<String> deletedEntries = [];
  List<StockEntryReceipt> stockEntryReceipts = [];
  late List<StockEntryReceipt> _filteredStock;
  StockEntryReceipt? _openDetail ;
  List<String> deletedDesignations = [];
  List<int> selectedIndicesBon = [];
  bool isRadioButtonChecked = false;
  bool _isAttributeListVisible = false;
  int? _selectedDetailIndex;
  bool _isArticlesListVisible = false;
  bool _isFiltered = false;
  String _referenceSearchText = '';
  String _designationSearchText = '';
  String _dateSearchText = '';
  String _totalSearchText = '';
  String _nbrarticlesSearchText = '';
  String _fournisseurSearchText = '';
  List<Article> _filteredArticlesDansBon = [];
  static const List<String> attributeNames = [
    'reference',
    'fournisseur',
    'nbr articles',
  ];
  static const List<String> attributeNamesArticlesBon = [
    'reference',
    'designation',
  ];
  String _selectedAttribute = attributeNames[0];
  String _selectedAttributeArticlesBon = attributeNamesArticlesBon[0];
  void initState() {
    super.initState();
    initializeDateFormatting();
    _articleService = ArticleService();
    _filteredStock = List.from(_originalStock);
    List<String> distinctDesignations = getDistinctDesignations();
    if (distinctDesignations.isNotEmpty) {
      selectedDesignation = distinctDesignations[0];
    }

    for (var designation in getDistinctDesignations()) {
      stockControllers[designation] = TextEditingController();
      priceControllers[designation] = TextEditingController();
    }
  }
  void updateStockAndPrice(String designation, int newStock, double newPrice) {
    setState(() {
      final index = dataRows.indexWhere((row) => (row.cells[0].child as Text).data! == designation);

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
        ...row.cells,
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  dataRows.removeAt(index);
                  double itemPrice = double.tryParse((row.cells[2].child as Text).data!) ?? 0.0;
                  total -= itemPrice;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final stockController = TextEditingController(text: stock.toString());
                    final priceController = TextEditingController(text: price.toString());

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
                            int newStock = int.tryParse(stockController.text ?? '') ?? 0;
                            double newPrice = double.tryParse(priceController.text ?? '') ?? 0.0;

                            updateStockAndPrice(designation, newStock, newPrice);
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
                  defaultVerticalAlignment: pdfWidgets.TableCellVerticalAlignment.middle,
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        for (var header in ["Désignation", "Stock", "Prix", "Fournisseur", "Date"])
                          pdfWidgets.Container(
                            padding: const pdfWidgets.EdgeInsets.all(8),
                            child: pdfWidgets.Text(header, style: pdfWidgets.TextStyle(fontWeight: pdfWidgets.FontWeight.bold)),
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
    final tempPath = path.join(tempDir!.path, 'stock_entrer_$pdfCounter.pdf'); // Append the counter value
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
    String searchValue = searchController.text.toLowerCase(); // Convert to lowercase
    List<String> designations = getDistinctDesignations()
        .map((designation) => designation.toLowerCase()) // Convert list to lowercase
        .toList();

    if (designations.contains(searchValue)) {
      setState(() {
        selectedDesignation = getDistinctDesignations()[designations.indexOf(searchValue)]; // Retrieve the original casing
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
      (row.cells[0].child as Text).data!.toLowerCase() == searchBarController.text.toLowerCase());

      if (articleExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("L'article existe déjà dans la liste."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          selectedDesignation = getDistinctDesignations()[designations.indexOf(searchValueAppBar)];
          updateDataTable(selectedDesignation);
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
    Article selectedArticle = articles.firstWhere((article) =>
    article.designation == selectedDesignation);
    bool articleExists = dataRows.any((row) =>
    (row.cells[0].child as Text).data!.toLowerCase() ==
        selectedDesignation.toLowerCase());

    if (!articleExists) {
      newDataRows.insert(0, DataRow(cells: [
        DataCell(Text(selectedArticle.designation)),
        DataCell(Text(selectedArticle.stock.toString())),
        DataCell(Text(selectedArticle.prix.toString())),
        DataCell(Text(DateFormat('dd-MM-yyyy').format(selectedDate))),
      ]));
      setState(() {
        dataRows = newDataRows.toList();
        double itemPrice = double.tryParse(selectedArticle.prix.toString()) ?? 0.0;
        total += itemPrice;
        searchBarController.clear();
      });
    }
  }
  void resetTotal() {
    double newTotal = 0.0;

    for (var row in dataRows) {
      double itemPrice = double.tryParse((row.cells[2].child as Text).data!) ?? 0.0;
      newTotal += itemPrice;
    }

    setState(() {
      total = newTotal;
    });
    stockEntryReceipts.clear();
  }
  void removeEntry(String designation) {
    deletedEntries.add(designation.toLowerCase());
    // Vous pouvez également ajouter des fonctionnalités de suppression dans dataRows ici
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
            (cell.child as Text).data!.toLowerCase().contains(searchValue.toLowerCase()));
      }).toList();
    });
  }
  List<String> getFilteredDesignations(String query) {
    List<String> distinctDesignations = getDistinctDesignations();
    return distinctDesignations.where((designation) => designation.toLowerCase().contains(query.toLowerCase())).toList();
  }
  void _searchBons({String reference = '', String nbr_articles = '', String fournisseur = ''}) {
    setState(() {
      _filteredStock = _originalStock.where((bon) {
        bool matchAttribute = true; // Initialize to true for "Tous" attribute

        if (_selectedAttribute == 'reference') {
          matchAttribute = bon.reference.toLowerCase().contains(reference.toLowerCase());
        } else if (_selectedAttribute == 'fournisseur') {
          matchAttribute = bon.fournisseur.toLowerCase().contains(fournisseur.toLowerCase());
        } else if (_selectedAttribute == 'nbr articles') {
          matchAttribute = bon.articles.length.toString().contains(nbr_articles);
        }

        return matchAttribute;
      }).toList();

      if (reference.isNotEmpty || fournisseur.isNotEmpty || nbr_articles.isNotEmpty) {
        // Apply additional filtering if any search field is not empty
        _filteredStock = _filteredStock.where((bon) {
          bool matchReference = bon.reference.toLowerCase().contains(reference.toLowerCase());
          bool matchFournisseur = bon.fournisseur.toLowerCase().contains(fournisseur.toLowerCase());
          bool matchNbrArticle = bon.articles.length.toString().contains(nbr_articles);

          return matchReference && matchFournisseur && matchNbrArticle;
        }).toList();
      }

      _isFiltered = true;
      _referenceSearchText = reference;
      _fournisseurSearchText = fournisseur;
      _nbrarticlesSearchText = nbr_articles;
    });
  }
  void _searchArticlesDansBon({String reference = '', String designation = ''}) {
    setState(() {
      if (reference.isEmpty && designation.isEmpty) {
        // Si les champs de recherche sont vides, réinitialisez la liste à la copie d'articles d'origine
        _filteredStock[_selectedDetailIndex!].articles = _originalStock[_selectedDetailIndex!].articles.toList();
      } else {
        _filteredStock[_selectedDetailIndex!].articles = _originalStock[_selectedDetailIndex!].articles.where((article) {
          bool matchAttribute = true;
          if (_selectedAttributeArticlesBon == 'reference') {
            matchAttribute = article.reference.toLowerCase().contains(reference.toLowerCase());
          } else if (_selectedAttributeArticlesBon == 'designation') {
            matchAttribute = article.designation.toLowerCase().contains(designation.toLowerCase());
          }
          return matchAttribute;
        }).toList();

        if (reference.isNotEmpty || designation.isNotEmpty) {
          // Appliquez un filtrage supplémentaire si l'un des champs de recherche n'est pas vide
          _filteredStock[_selectedDetailIndex!].articles = _filteredStock[_selectedDetailIndex!].articles.where((article) {
            bool matchReference = article.reference.toLowerCase().contains(reference.toLowerCase());
            bool matchDesignation = article.designation.toLowerCase().contains(designation.toLowerCase());
            return matchReference && matchDesignation;
          }).toList();
        }

      }

      _isFiltered = true;
      _referenceSearchText = reference;
      _designationSearchText = designation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row( // Wrap the content in a Row
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /////////: chaps input de filter bon
            Visibility(visible: isListVisible && !_isArticlesListVisible,
              child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 250,
                  height: 45,
                  child: TextField(
                    controller: _searchTextController,
                    decoration: InputDecoration(
                      labelText: 'Recherche',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                    ),
                    onChanged: (value) {
                      _searchBons(
                        reference: _selectedAttribute == 'reference' ? _searchTextController.text : '',
                        fournisseur: _selectedAttribute == 'fournisseur' ? _searchTextController.text : '',
                        nbr_articles: _selectedAttribute == 'nbr articles' ? _searchTextController.text : '',
                      );
                    },
                  ),
                ),
              ),
            ),
            //:::input search articles de bon selectre///:
            Visibility(visible: _isArticlesListVisible,
              child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 250,
                  height: 45,
                  child: TextField(
                    controller: _searchTextArticleController,
                    decoration: InputDecoration(
                      labelText: 'Recherche...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                    ),
                    onChanged: (value) {
                      _searchArticlesDansBon(
                        reference: _selectedAttributeArticlesBon == 'reference' ? _searchTextArticleController.text : '',
                        designation: _selectedAttributeArticlesBon == 'designation' ? _searchTextArticleController.text : '',
                      );
                    },
                  ),
                ),
              ),),

            Spacer(),
            //////////champs recherch par designaton
            Visibility(visible: !isListVisible && !_isArticlesListVisible,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par désignation',
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedDesignation = value;
                        filteredDesignations = getFilteredDesignations(value).toSet().toList();
                      });

                      if (!filteredDesignations.contains(selectedDesignation)) {
                        if (filteredDesignations.isNotEmpty) {
                          selectedDesignation = filteredDesignations[0];
                        } else {
                          selectedDesignation = '';
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !isListVisible && !_isArticlesListVisible,
              child: Container(
                height: 45,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedDesignation,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDesignation = newValue!;
                    });
                    if (selectedDesignation.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("La sélection de la désignation est obligatoire."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      bool containsDifferentFournisseur = dataRows.any((row) =>
                      (row.cells[3].child as Text).data!.toLowerCase() !=
                          selectedFournisseur.toLowerCase());

                      if (containsDifferentFournisseur) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("La liste doit contenir le même fournisseur."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (dataRows.any((row) =>
                      (row.cells[0].child as Text).data!.toLowerCase() ==
                          selectedDesignation.toLowerCase())) {
                        prixController.clear();
                        stockController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("L'article existe déjà dans la liste."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        List<Article> articles = _articleService.getArticles();
                        Article selectedArticle = articles.firstWhere((article) =>
                        article.designation == selectedDesignation);
                        dataRows.add(DataRow(cells: [
                          DataCell(Text(selectedArticle.designation)),
                          DataCell(Text(selectedArticle.stock.toString())),
                          DataCell(Text(selectedArticle.prix.toString())),
                          DataCell(Text(DateFormat('dd-MM-yyyy').format(selectedDate))),
                        ]));
                        setState(() {
                          double itemPrice = double.tryParse(selectedArticle.prix.toString()) ?? 0.0;
                          total += itemPrice;
                        });
                      }
                    }
                  },
                  items: getDistinctDesignations().map((designation) {
                    return DropdownMenuItem<String>(
                      value: designation,
                      child: Text(designation),
                    );
                  }).toList(),
                  icon: Icon(Icons.arrow_drop_down),
                  underline: SizedBox(),
                ),
              ),
            ),
            Visibility(
              visible: isListVisible && !_isArticlesListVisible,
              child:
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4eb5ec),
                  minimumSize: Size(120, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF4eb5ec), width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                onPressed: () async {
                  if (selectedIndices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Aucun bon sélectionné à générer en PDF."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    final pdf = pdfWidgets.Document();

                    final titleStyle = pdfWidgets.TextStyle(
                      fontSize: 24,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    );

                    for (var selectedIndex in selectedIndices) {
                      final StockEntryReceipt receipt = _filteredStock[selectedIndex];

                      pdf.addPage(
                        pdfWidgets.Page(
                          build: (context) {
                            return pdfWidgets.Center(
                              child: pdfWidgets.Column(
                                mainAxisAlignment: pdfWidgets.MainAxisAlignment.center,
                                children: [
                                  pdfWidgets.Text("Entrée stock", style: titleStyle),
                                  pdfWidgets.SizedBox(height: 20),
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
                                            "Date",
                                            "Articles"
                                          ])
                                            pdfWidgets.Container(
                                              padding: const pdfWidgets.EdgeInsets.all(8),
                                              child: pdfWidgets.Text(header,
                                                  style: pdfWidgets.TextStyle(
                                                      fontWeight: pdfWidgets.FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      pdfWidgets.TableRow(
                                        children: [
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Text(receipt.reference),
                                          ),
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Text(
                                                receipt.articles.length.toString()),
                                          ),
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Text(
                                                DateFormat('dd-MM-yyyy')
                                                    .format(receipt.date)),
                                          ),
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Text(receipt.fournisseur),
                                          ),
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Text(
                                                receipt.total.toStringAsFixed(2)),
                                          ),
                                          pdfWidgets.Container(
                                            padding: const pdfWidgets.EdgeInsets.all(8),
                                            child: pdfWidgets.Container(
                                              padding: const pdfWidgets.EdgeInsets.all(8),
                                              child: pdfWidgets.Column(
                                                crossAxisAlignment:
                                                pdfWidgets.CrossAxisAlignment.start,
                                                children: receipt.articles
                                                    .map((article) => pdfWidgets.Text(
                                                    '${article.designation} (Stock: ${article.stock}, Prix: ${article.prix})'))
                                                    .toList(),
                                              ),
                                            ),
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
                    }

                    selectedIndices.clear();
                    setState(() {
                      isRadioButtonChecked = false; // Décoche le bouton
                    });
                    final tempDir = await getDownloadsDirectory();
                    final tempPath =
                    path.join(tempDir!.path, 'stock_entrer_$pdfCounter.pdf');
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
                icon: Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                label: Text('Imprimer PDF', style: TextStyle(color: Colors.white)),
              ),
            ),
            ///////: boutton 'Nouvelle entréé ' : 'Bons entrés',
            SizedBox(width: 10 ),
            Visibility(visible: !_isArticlesListVisible ,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isListVisible = !isListVisible;
                  });
                },
                icon: Icon(
                  isListVisible ? Icons.add : Icons.list ,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  isListVisible ? 'Nouvelle entréé ' : 'Bons entrés',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF067487),
                  minimumSize: Size(120, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF067487), width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
              ),),
            ///////////:bouton dans container de detail bon
            Visibility(visible: _isArticlesListVisible ,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isArticlesListVisible = !_isArticlesListVisible;
                    _selectedDetailIndex = null;
                  });
                },
                icon: Icon(
                  Icons.list ,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Retour à la liste de bons',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF067487),
                  minimumSize: Size(120, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF067487), width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
              ),),
            ///////////:: boutton filter
            Visibility(visible:_isArticlesListVisible,
              child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.filter_alt, color: Colors.purple, size: 30),
                  itemBuilder: (BuildContext context) {
                    return attributeNamesArticlesBon.map((String attributeNamesArticlesBon) {
                      return PopupMenuItem<String>(
                        value: attributeNamesArticlesBon,
                        child: Text(attributeNamesArticlesBon),
                      );
                    }).toList();
                  },
                  onSelected: (String selectedAttribute) {
                    setState(() {
                      _selectedAttributeArticlesBon = selectedAttribute;
                    });
                  },
                ),
              ),
            ),
///////////////////////////////////filter de articles des bon///////////////:
            Visibility(visible: isListVisible && !_isArticlesListVisible,
              child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.filter_alt, color: Colors.purple, size: 30),
                  itemBuilder: (BuildContext context) {
                    return attributeNamesArticlesBon.map((String attributeName) {
                      return PopupMenuItem<String>(
                        value: attributeName,
                        child: Text(attributeName),
                      );
                    }).toList();
                  },
                  onSelected: (String selectedAttribute) {
                    setState(() {
                      _selectedAttributeArticlesBon = selectedAttribute;
                    });
                  },
                ),
              ),
            ),

          ],
        ),
      ),
      body:  Container(
        padding: EdgeInsets.all(16),
        child:
        !isListVisible
            ?Column(
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
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.all(8),
              //color: Color(0xFFE4E8FF),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    width: 180,
                    height: 44,// Adjust the width as needed
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
                  SizedBox(width: 8,),
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
                  SizedBox(width: 9,),
                  SizedBox(width: 10,),
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
                          Icon(Icons.calendar_today, color: Colors.black38),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('dd-MM-yyyy').format(selectedDate), // Format the date as you want
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (selectedDate == null ||
                          searchController.text.isEmpty ||
                          selectedFournisseur.isEmpty ||
                          prixController.text.isEmpty ||
                          stockController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Veuillez remplir tous les champs."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        bool containsDifferentFournisseur = dataRows.any((row) =>
                        (row.cells[3].child as Text).data!.toLowerCase() !=
                            selectedFournisseur.toLowerCase());

                        if (containsDifferentFournisseur) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("La liste doit contenir le même fournisseur."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (dataRows.any((row) =>
                        (row.cells[0].child as Text).data!.toLowerCase() ==
                            selectedDesignation.toLowerCase())) {
                          searchController.clear();
                          prixController.clear();
                          stockController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("L'article existe déjà dans la liste."),
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
                            DataCell(Text(DateFormat('dd-MM-yyyy').format(selectedDate))),
                          ]));
                          double itemPrice = double.tryParse(prixController.text) ?? 0.0;
                          total += itemPrice;
                          searchController.clear();
                          prixController.clear();
                          stockController.clear();
                          setState(() {});
                        }
                      }
                    },
                    icon: Icon(Icons.add, color: Colors.white, size: 20),
                    label: Text('Ajouter', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF19cfbe),
                      minimumSize: Size(120, 49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xFF19cfbe), width: 1.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                  headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF067487),),
                  headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200,color: Colors.black54),
                  ),
                ),
              ),
            ),
            Divider(thickness: 1,color: Colors.black26,),
            Container(
              height: 45.0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Total : $total DT         Nbr articles: ${dataRows.length}' ,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: dataRows.isEmpty
                        ? null
                        : () {
                      print('Before adding new receipt');
                      String uniqueReference = generateUniqueReference(); // Generate a unique reference
                      StockEntryReceipt newReceipt = StockEntryReceipt(
                        reference: uniqueReference,
                        fournisseur: selectedFournisseur,
                        date: selectedDate,
                        articles: dataRows.map((row) {
                          String designation = (row.cells[0].child as Text).data!;
                          String stock = (row.cells[1].child as Text).data!;
                          String prix = (row.cells[2].child as Text).data!;
                          return Article(
                            designation: designation,
                            stock: stock,
                            prix: prix,
                            reference: '',
                            codeBarre: '',
                            categorie: '',
                            imageUrl: '',
                          );
                        }).toList(),
                        total: total,
                      );
                      print('After adding new receipt');
                      stockEntryReceipts.add(newReceipt);
                      resetTotal();

                      setState(() {
                        isListVisible = true;
                      });
                    },
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(120, 49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(width: 1.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(width: 25,),
                ],
              ),
            ),

          ],
        ):
        Container(
          padding: EdgeInsets.all(16),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isArticlesListVisible)
                Expanded(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 25),
                      Align(
                        alignment: Alignment.topLeft,
                        child:Text(
                          "Bons des entrés stock",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child:DataTable(
                              columnSpacing: 100.0,
                              dataRowHeight: 45.0,
                              headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF067487),),
                              headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              dividerThickness: 1.0,
                              columns: [
                                DataColumn(label: Container()),
                                DataColumn(label: Text('Réference')),
                                DataColumn(label: Text('Fournisseur')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Nbr articles')),
                                DataColumn(label: Text('Total')),
                                DataColumn(label: Text('Articles')),
                              ],
                              rows: _filteredStock.asMap().entries.map((stock) {
                                final int index = stock.key;
                                final StockEntryReceipt receipt = stock.value ;

                                return DataRow(
                                  color: MaterialStateColor.resolveWith((states) {
                                    return index % 2 == 0 ? Colors.white : Colors.black12;
                                  }),
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: Checkbox(
                                          value: selectedIndices.contains(index),
                                          onChanged: (value) {
                                            setState(() {
                                              if (selectedIndices.contains(index)) {
                                                selectedIndices.remove(index);
                                              } else {
                                                selectedIndices.add(index);
                                              }
                                              isRadioButtonChecked = selectedIndices.isNotEmpty;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(receipt.reference)),
                                    DataCell(Text(receipt.fournisseur)),
                                    DataCell(Text(DateFormat.yMMMMd('fr_FR').format(receipt.date))),
                                    DataCell(Text(receipt.articles.length.toString())),
                                    DataCell(Text(receipt.total.toStringAsFixed(2))),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.list, color: Colors.black54),
                                          onPressed: () {
                                            setState(() {
                                              _selectedDetailIndex = index; // Store the selected index
                                              _isArticlesListVisible = true;
                                            });
                                            // showDialog(
                                            //   context: context,
                                            //   builder: (context) {
                                            //     return AlertDialog(
                                            //       title: Text('Articles pour ${receipt.reference}'),
                                            //       content: ConstrainedBox(
                                            //         constraints: BoxConstraints(maxHeight: 150),
                                            //         child: Column(
                                            //           crossAxisAlignment: CrossAxisAlignment.start,
                                            //           children: receipt.articles.map((article) {
                                            //             return ListTile(
                                            //               title: Text(article.designation),
                                            //               subtitle: Column(
                                            //                 crossAxisAlignment: CrossAxisAlignment.start,
                                            //                 children: [
                                            //                   Text('Stock: ${article.stock}'),
                                            //                   Text('Prix: ${article.prix.toStringAsFixed(2)}'),
                                            //                 ],
                                            //               ),
                                            //             );
                                            //           }).toList(),
                                            //         ),
                                            //       ),
                                            //       actions: [
                                            //         TextButton(
                                            //           onPressed: () {
                                            //             Navigator.of(context).pop();
                                            //           },
                                            //           child: Text('Fermer'),
                                            //         ),
                                            //       ],
                                            //     );
                                            //   },
                                            // );
                                          },
                                        ),
                                      ],
                                    )),
                                  ],
                                );

                              }).toList(),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              if (_selectedDetailIndex != null)
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: double.infinity, // Largeur maximale du Container
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 15),
                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Text(
                              "Référence du bon : ${_filteredStock[_selectedDetailIndex!].reference}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 275.0,
                                dataRowHeight: 45.0,
                                headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF067487),),
                                headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                dividerThickness: 1.0,
                                columns: [
                                  DataColumn(label: Text('Référence')),
                                  DataColumn(label: Text('Désignation')),
                                  DataColumn(label: Text('Stock')),
                                  DataColumn(label: Text('Prix')),
                                ],
                                rows: _filteredStock[_selectedDetailIndex!].articles.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final Article article = entry.value;

                                  return DataRow(
                                    color: MaterialStateColor.resolveWith((states) {
                                      return index % 2 == 0 ? Colors.white : Colors.black12;
                                    }),
                                    cells: [
                                      DataCell(Text(article.reference)),
                                      DataCell(Text(article.designation)),
                                      DataCell(Text(article.stock.toString())),
                                      DataCell(Text(article.prix)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  void _resetSearch() {
    setState(() {
      referenceController.clear();
      _fournisseurController.clear();
      _totalController.clear();
      _dateController.clear();
      nbrArticlesController.clear();
      _filteredStock = List.from(_originalStock);
    });
  }
  void _filterStockEntries() {
    setState(() {
      _filteredStock = _originalStock.where((receipt) {
        final refFilter = referenceController.text.toLowerCase();
        final fournisseurFilter = _fournisseurController.text.toLowerCase();
        final totalFilter = _totalController.text.toLowerCase();
        final dateFilter = _dateController.text.toLowerCase();
        final nbrArticlesFilter = nbrArticlesController.text.toLowerCase();

        return receipt.reference.toLowerCase().contains(refFilter) &&
            receipt.fournisseur.toLowerCase().contains(fournisseurFilter) &&
            receipt.total.toString().toLowerCase().contains(totalFilter) &&
            receipt.articles.length.toString().toLowerCase().contains(nbrArticlesFilter) &&
            DateFormat.yMMMMd('fr_FR').format(receipt.date).toLowerCase().contains(dateFilter);
      }).toList();
    });
  }

  String generateUniqueReference() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "ENTR-$timestamp";
  }

  List<String> getDistinctDesignations() {
    return _articleService.getArticles().map((article) => article.designation).toSet().toList();
  }


}
