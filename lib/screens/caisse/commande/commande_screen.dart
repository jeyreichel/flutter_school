import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/article.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../../../models/commande.dart';
import '../../../models/historique_utlisateur_commande.dart';
import '../../../services/article_service.dart';
import '../../logn/login.dart';

class CommandePage extends StatefulWidget {
  @override
  _CommandePageState createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  String _selectedCategory = '';
  List<String> _categories = [];
  double totalTTC = 0;
  List<Article> _selectedCategoryArticles = [];
  int numberOfColumns = 5;
  List<Map<String, dynamic>> _articles = [];
  late CategorieService _categorieService;
  late ArticleService _articleService;
  List<CartItem> _cartItems = [];
  String _cartTotal = '0';
  GlobalKey<State> confirmationDialogKey = GlobalKey<State>();
  String barcodeValue = ''; // Variable pour stocker la valeur du code à barres
  String referenceValue = ''; // Variable pour stocker la valeur de la référence
  TextEditingController _barcodeController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  CartItem? _selectedCartItem;
  String pdfFilePath = "";
  TextEditingController _quantityInputController = TextEditingController();
  CartItem? _selectedItem;
  bool _preferredButtonClicked = false;
  List<HistoriqueCommande> historiqueCommandes = [];

  FieldToUpdate _fieldToUpdate = FieldToUpdate.Quantity;
  TextEditingController _priceInputController = TextEditingController();
  TextEditingController _discountInputController = TextEditingController();
  int _currentPage = 0;
  int _totalPages = 0;
  int _currentCategoryPage = 0;
  int _categoriesPerPage = 6; // Nombre de catégories par page
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _categorieService = CategorieService();
    _articleService = ArticleService();
    _categories = _categorieService
        .getCategories()
        .map((category) => category.name)
        .toList();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories[0];
      _selectedCategoryArticles =
          _articleService.getArticlesByCategory(_selectedCategory);
    }
    calculerTotalTTC();
  }

  void calculerTotalTTC() {
    totalTTC = 0;
    _cartItems.forEach((cartItem) {
      double articleTotal = double.parse(cartItem.price) * cartItem.quantity;
      totalTTC += articleTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 0,
              child: Container(
                width: 40,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward_outlined,
                            color: Colors.black45),
                        onPressed: _goToPreviousPage,
                      ),
                      SizedBox(height: 90),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_outlined,
                            color: Colors.black45),
                        onPressed: _goToNextPage,
                      ),
                      SizedBox(height: 200),
                      IconButton(
                        icon: Icon(Icons.arrow_upward_outlined,
                            color: Colors.black45),
                        onPressed: _goToPreviousCategoryPage,
                      ),
                      SizedBox(height: 70),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_outlined,
                            color: Colors.black45),
                        onPressed: _goToNextCategoryPage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: Colors.white,
                          actions: [
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 8.0),
                            //   child: Icon(Icons.qr_code_scanner,
                            //       color: Colors.black),
                            // ),
                            // Expanded(
                            //   child: TextField(
                            //     controller: _barcodeController,
                            //     onChanged: (value) {
                            //       searchByBarcodeOrReference(value);
                            //     },
                            //     decoration: InputDecoration(
                            //       labelText: 'Code à barres',
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 8.0),
                            //   child: Icon(Icons.search, color: Colors.black),
                            // ),
                            // Expanded(
                            //   child: TextField(
                            //     controller: _referenceController,
                            //     onChanged: (value) {
                            //       searchByBarcodeOrReference(value);
                            //     },
                            //     decoration: InputDecoration(
                            //       labelText: 'Référence',
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categories')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            List<Map<String, dynamic>> acategoriesData =
                                snapshot.data!.docs.map((doc) {
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              return {
                                'name': data['name'],
                                //'imageUrl': data['imageUrl'],
                              };
                            }).toList();

                            return Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  mainAxisSpacing: 3.0,
                                  crossAxisSpacing: 3.0,
                                ),
                                itemCount: acategoriesData.length,
                                itemBuilder: (context, index) {
                                  final categorieData = acategoriesData[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 3.0),
                                    child: _buildArticleButton(
                                        categorieData, index),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          // Colonne "left"
                          Expanded(
                            flex: 2,
                            child: Container(
                              // color: Colors.black12,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: _buildArticleRows(_articles),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          // Colonne "centre"
                          Expanded(
                            flex: 1,
                            child: Container(
                              //color: Colors.black12,
                              child: Align(
                                // alignment: Alignment.bottomCenter,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _quantityInputController,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle:
                                            TextStyle(color: Colors.black54),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 25),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black12,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                      ),
                                      // Inside the onChanged method for each text field
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberButton('1'),
                                        _buildNumberButton('2'),
                                        _buildNumberButton('3'),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberButton('4'),
                                        _buildNumberButton('5'),
                                        _buildNumberButton('6'),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberButton('7'),
                                        _buildNumberButton('8'),
                                        _buildNumberButton('9'),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _clearInput,
                                          icon: Icon(Icons.backspace_outlined,
                                              color: Colors.black54, size: 20),
                                          label: SizedBox.shrink(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              side: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1.0),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14.5, horizontal: 15),
                                            // Ajustez les valeurs de padding ici
                                            minimumSize: Size(30,
                                                30), // Ajustez la taille minimale du bouton ici
                                          ),
                                        ),
                                        _buildNumberButton('0'),
                                        _buildNumberButton('.'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          // Colonne "right"
                          Expanded(
                            flex: 0,
                            child: Container(
                              //color: Colors.black12,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: IntrinsicWidth(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _fieldToUpdate =
                                                  FieldToUpdate.Quantity;
                                              _preferredButtonClicked = true;
                                              if (_selectedCartItem != null) {
                                                int newQuantity = int.tryParse(
                                                        _quantityInputController
                                                            .text) ??
                                                    0;
                                                if (newQuantity >= 0) {
                                                  _selectedCartItem!.quantity =
                                                      newQuantity;
                                                  _updateTotal();
                                                }
                                              }
                                              _quantityInputController.text =
                                                  "";
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black54,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              side: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1.0),
                                            ),
                                            minimumSize: Size(80,
                                                80.0),
                                          ),
                                          child: Text('Quantité',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _fieldToUpdate =
                                                  FieldToUpdate.Price;
                                              _preferredButtonClicked = true;
                                              if (_selectedCartItem != null) {
                                                double newPrice = double.tryParse(
                                                        _quantityInputController
                                                            .text) ??
                                                    0.0;
                                                if (newPrice >= 0) {
                                                  _selectedCartItem!.price =
                                                      newPrice
                                                          .toStringAsFixed(2);
                                                  _updateTotal();
                                                }
                                              }
                                              _quantityInputController.text =
                                                  "";
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black54,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              side: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1.0),
                                            ),
                                            minimumSize: Size(92, 80.0),
                                          ),
                                          child: Text('Prix',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _fieldToUpdate =
                                                  FieldToUpdate.Quantity;
                                              _preferredButtonClicked = true;
                                              if (_selectedCartItem != null) {
                                                int newPriceRemise = int.tryParse(
                                                        _quantityInputController
                                                            .text) ??
                                                    0;
                                                double maxDiscount =
                                                    double.parse(
                                                            _selectedCartItem!
                                                                .price) *
                                                        _selectedCartItem!
                                                            .quantity;
                                                if (newPriceRemise >= 0 &&
                                                    newPriceRemise <=
                                                        maxDiscount) {
                                                  double updatedPrice =
                                                      maxDiscount -
                                                          newPriceRemise;
                                                  _selectedCartItem!.price =
                                                      updatedPrice
                                                          .toStringAsFixed(2);
                                                  _updateTotal();
                                                }
                                              }
                                              _quantityInputController.text =
                                                  "";
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black54,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              side: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1.0),
                                            ),
                                            minimumSize: Size(91, 80.0),
                                          ),
                                          child: Text('Remise',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _removeFromCartFromBottom();
                          },
                          icon: Icon(Icons.remove, color: Colors.black87),
                        ),
                        Spacer(),

                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Expanded(
                      child: _cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart,
                                      size: 65, color: Colors.black26),
                                  SizedBox(height: 10),
                                  Text(
                                    'Panier vide',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black26),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final cartItem = _cartItems[index];
                                double articleTotal =
                                    double.parse(cartItem.price) *
                                        cartItem.quantity;
                                Color itemBackgroundColor = index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[200]!;

                                return Container(
                                  color: itemBackgroundColor,
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        _selectedCartItem = cartItem;
                                      });
                                    },
                                    title: Text(
                                      cartItem.title.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    subtitle: Text(' x ${cartItem.quantity}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${articleTotal.toStringAsFixed(3)} DT',
                                          // Affichage du prix total de l'article
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10), // Espacement
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _removeFromCart(cartItem);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16.0),
                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total TTC:',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Total TTC: ${totalTTC.toStringAsFixed(3)}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            // Expanded(
                            //   flex: 0,
                            //   child: ElevatedButton(
                            //     onPressed: () {},
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Color(0xFF4eb5ec),
                            //       padding: EdgeInsets.all(16.0),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //         side: BorderSide(
                            //             color: Colors.black12, width: 1.0),
                            //       ),
                            //       minimumSize: Size(120, 50),
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Icon(Icons.payment, color: Colors.white),
                            //         SizedBox(width: 8),
                            //         Text(""),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                           // SizedBox(width: 5),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_cartItems.isEmpty) {
                                    _scaffoldMessengerKey.currentState!
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text("Le panier est vide."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    // Référence à la collection "commandes" dans Firestore
                                    CollectionReference commandes =
                                        FirebaseFirestore.instance
                                            .collection('commandes');
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String? idUser =
                                        await prefs.getString('loggedInUserId');
                                    Random random = Random();
                                    int idCommande = random.nextInt(9900) + 100;
                                    // Générer une nouvelle commande
                                    DocumentReference newCommandeRef =
                                        await commandes.add({
                                      'idCommande': idCommande,
                                      'idUser': idUser,
                                      'articles': _cartItems.map((item) {
                                        return {
                                          'designation': item.title,
                                          'prix': item.price,
                                          'quantite': item.quantity,
                                        };
                                      }).toList(),
                                      'totalTTC': totalTTC,
                                      'date': DateTime.now(),
                                      'status': 'en attente'
                                    });
                                    await newCommandeRef.update({'id': newCommandeRef.id});
                                    print(
                                        'Commande ajoutée avec succès ! ID de la commande : ${newCommandeRef.id}');

                                    // Effacer le panier après avoir passé la commande
                                    setState(() {
                                      _cartItems.clear();
                                      calculerTotalTTC();
                                    });
                                  } catch (e) {
                                    print(
                                        'Erreur lors de l\'ajout de la commande : $e');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4eb5ec),
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                        color: Colors.black12, width: 1.0),
                                  ),
                                  minimumSize: Size(120, 50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_forward,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Passer la commande",
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await showPendingOrdersAlert();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFffa923),
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                        color: Colors.black12, width: 1.0),
                                  ),
                                  minimumSize: Size(120, 50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timer, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Commandes en attente",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              //flex: 1,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    bool confirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text("Voulez-vous vraiment fermer la caisse ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                              child: Text("Annuler"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text("Confirmer"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed) {
                                      // L'utilisateur a confirmé, ajoutez les données à Firestore
                                      addDataToFirestore();
                                    }

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                        color: Colors.black12, width: 1.0),
                                  ),
                                  minimumSize: Size(120, 50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Cloturer",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (_selectedCartItem != null && _cartItems.isNotEmpty)
                      Expanded(
                        flex: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Article sélectionné:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            ListTile(
                              title: Text(
                                _selectedCartItem!.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                  'Quantité: ${_selectedCartItem!.quantity}'),
                              trailing: Text(
                                '${(_selectedCartItem!.quantity * double.parse(_selectedCartItem!.price)).toStringAsFixed(3)} DT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCartItem = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                      color: Colors.black12, width: 1.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.remove_circle_outline,
                                      color: Colors.white),
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Annuler la sélection',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showPendingOrdersAlert() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUserId');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('commandes')
        .where('status', isEqualTo: 'en attente').where('idUser', isEqualTo: loggedInUserId)
        .get();

    List<QueryDocumentSnapshot> pendingOrders = snapshot.docs;

    if (pendingOrders.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Commandes en attente'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pendingOrders.map((order) {
                  Map<String, dynamic>? data =
                      order.data() as Map<String, dynamic>?;
                  int id = data?['idCommande'] ?? 0;
                  double total = data?['totalTTC'] ?? 0.0;
                  String date = DateFormat('yyyy-MM-dd HH:mm')
                      .format((data?['date'] as Timestamp).toDate());
                  String idbase = data?['id'] ?? '';

                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmer la commande'),
                                content: Text('Voulez-vous confirmer la commande ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      // Convertir l'ID en chaîne
                                      String orderId = idbase.toString();

                                      // Rechercher le document correspondant à l'ID cliqué
                                      DocumentSnapshot doc = await FirebaseFirestore.instance
                                          .collection('commandes')
                                          .doc(orderId)
                                          .get();

                                      // Vérifier si le document existe
                                      if (doc.exists) {
                                        // Mettre à jour le statut de la commande dans Firestore
                                        await FirebaseFirestore.instance
                                            .collection('commandes')
                                            .doc(orderId)
                                            .update({'status': 'payé'});
                                        setState(() {
                                          Navigator.of(context).pop();
                                        });

                                        Navigator.of(context).pop();
                                      } else {
                                        // Le document n'existe pas, afficher un message d'erreur
                                        print('Document non trouvé pour l\'ID : $orderId');
                                        // Afficher un message d'erreur ou effectuer une autre action
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text('Confirmer'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Annuler'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Commande: $id'),
                            SizedBox(height: 4),
                            Text('Total: ${total.toStringAsFixed(2)} DT'),
                            SizedBox(height: 4),
                            Text('Date: $date'),
                          ],
                        ),
                      ));
                }).toList(),
              ),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Aucune commande en attente'),
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
    }
  }

  Future<void> addCategory() async {
    try {
      // Référence à la collection "categories" dans Firestore
      CollectionReference commandes =
          FirebaseFirestore.instance.collection('commandes');

      // Ajouter un nouveau document avec un ID généré automatiquement
      DocumentReference docRef = await commandes.add({});

      // Obtenir l'ID généré par Firestore et mettre à jour le document avec cet ID
      await docRef.update({'id': docRef.id});

      print('commandes ajoutée avec succès !');
    } catch (e) {
      print('Erreur lors de l\'ajout de la commandes : $e');
    }
  }

  void _addToCart(Map<String, dynamic> articleData) {
    setState(() {
      CartItem newItem = CartItem(
        title: articleData['designation'] ?? '',
        price:
            articleData['prix'] != null ? articleData['prix'].toString() : '0',
        quantity: 1,
      );

      // Vérifier si l'article existe déjà dans le panier
      bool existsInCart = _cartItems.any((item) => item.title == newItem.title);

      if (existsInCart) {
        // Mettre à jour la quantité si l'article existe déjà
        _cartItems.forEach((item) {
          if (item.title == newItem.title) {
            item.quantity++;
          }
        });
      } else {
        // Ajouter l'article au panier s'il n'existe pas déjà
        _cartItems.add(newItem);
      }

      calculerTotalTTC();
    });
  }

  Widget _buildArticleRows(List<Map<String, dynamic>> articles) {
    List<Widget> rows = [];
    int numberOfEmptyCells =
        articles.length % 3 == 0 ? 0 : 3 - articles.length % 3;
    List<Widget> emptyCells = List.generate(
      numberOfEmptyCells,
      (index) => Expanded(
          child: SizedBox()), // Crée des cellules vides pour compléter la ligne
    );

    for (int i = 0; i < articles.length; i += 3) {
      List<Widget> rowChildren = [];
      for (int j = i; j < i + 3 && j < articles.length; j++) {
        rowChildren.add(
          Expanded(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: _buildArticleButtonnnnnnn(articles[j]),
            ),
          ),
        );
      }
      rowChildren.addAll(
          emptyCells); // Ajoute les cellules vides à la fin de la ligne si nécessaire
      rows.add(
        Row(
          children: rowChildren,
        ),
      );
    }

    return Column(
      children: rows,
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          // content: Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text("Que souhaitez-vous faire ?"),
          // ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                bool confirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmation"),
                      content: Text("Voulez-vous vraiment fermer la caisse ?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("Confirmer"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed) {
                  // L'utilisateur a confirmé, ajoutez les données à Firestore
                  addDataToFirestore();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: Size(150, 45),
              ),
              child: Text(
                "X",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(150, 45)),
              child: Text("Z",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  Future<void> addDataToFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUserId');
    String? loginDateTime = prefs.getString('loginDateTime');
    DateTime dateCloseCaisse = DateTime.now();
    dateCloseCaisse = DateTime(dateCloseCaisse.year, dateCloseCaisse.month, dateCloseCaisse.day);

    if (loginDateTime != null) {
      QuerySnapshot commandesSnapshot = await FirebaseFirestore.instance
          .collection('commandes')
          .where('idUser', isEqualTo: loggedInUserId)
          .get();

      // Create a list to hold the command data
      List<Map<String, dynamic>> commandesData = [];
      commandesSnapshot.docs.forEach((doc) {
        if (doc.data() is Map<String, dynamic>) {
          commandesData.add(doc.data() as Map<String, dynamic>);
        }
      });

      Random random = Random();
      int idCaisse = random.nextInt(9900) + 100;
      // Create a new object with the data to add to Firestore
      Map<String, dynamic> caisseData = {
        'IdCaisse': idCaisse,
        'loggedInUserId': loggedInUserId,
        'loginDateTime': loginDateTime,
        'date_close_caisse': dateCloseCaisse,
        'commandes': commandesData,
      };

      // Add the document to the 'caisses' collection in Firestore
      await FirebaseFirestore.instance.collection('caisses').add(caisseData);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void afficherArticlesHistorique(String userId,
      List<HistoriqueCommande> historiqueCommandes, BuildContext context) {
    List<CartItem> articlesTrouves = [];

    for (HistoriqueCommande historiqueCommande in historiqueCommandes) {
      if (historiqueCommande.userId == userId) {
        for (CartItem article in historiqueCommande.articles) {}
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Articles de l\'historique'),
          content: ListView.builder(
            itemCount: articlesTrouves.length,
            itemBuilder: (context, index) {
              CartItem article = articlesTrouves[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text('Quantité: ${article.quantity}'),
                trailing: Text('Prix: ${article.price}'),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> generateAndSavePDF() async {
    final pdf = pw.Document();

    final titleStyle = pw.TextStyle(
      fontSize: 15,
      fontWeight: pw.FontWeight.normal,
    );

    final List<pw.Widget> itemList = [];

    itemList.addAll([
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 18.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Qte',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
                pw.Text('Article',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
                pw.Text('Prix',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
              ],
            ),
            pw.SizedBox(height: 3),
          ],
        ),
      ),
      pw.Divider(
        thickness: 1,
        color: PdfColors
            .grey, // Remplacez PdfColors.blue par la couleur que vous souhaitez
      ),
    ]);
    for (var cartItem in _cartItems) {
      final itemTotal = cartItem.quantity * double.parse(cartItem.price);
      double itemPrice;

      if (cartItem.quantity > 1) {
        // Si la quantité est supérieure à 1, calculez le prix total
        itemPrice = cartItem.quantity * double.parse(cartItem.price);
      } else {
        // Sinon, utilisez le prix tel quel
        itemPrice = double.parse(cartItem.price);
      }
      itemList.add(pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 18.0),
        // Ajustez la valeur pour l'espace souhaité à gauche et à droite
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${cartItem.quantity.toString()} ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(cartItem.title),
                pw.Text(itemPrice.toString()),
                // Utilisez le prix calculé ici
              ],
            ),
            pw.SizedBox(height: 3),
          ],
        ),
      ));

      // Add space between the lines
      itemList.add(pw.SizedBox(height: 1)); // Adjust the height as needed
    }

    final double pageWidthMm = 90.0; // 80mm
    final double pageHeightMm = 150.0; // 40mm

    final double pageWidthPoints =
        (pageWidthMm * 2.83465); // Approximately 2.83465 points per millimeter
    final double pageHeightPoints = (pageHeightMm * 2.83465);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(pageWidthPoints, pageHeightPoints),
        build: (context) {
          // Content of your PDF page
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 10),
                pw.Text("Nom de restaurant", style: titleStyle),
                pw.SizedBox(height: 10),
                // Add some spacing
                pw.Text(
                  'Tel: 23456789',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey,
                  ),
                ),
                //
                pw.SizedBox(height: 5),
                pw.Text(
                  'Adresse: Sahloul, prés ...',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 5),
                // pw.Text('**************************************************', style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                pw.Text(
                  '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal())}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                    '***********************************************************',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),

                pw.SizedBox(height: 5),

                ...itemList,
                pw.SizedBox(height: 12),

                pw.Text(
                    '---------------------------------------------------------------------',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.black)),

                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 18.0),
                  // Ajustez la valeur pour l'espace souhaité à gauche et à droite
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total :',
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${_cartTotal} DT',
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.Text(
                    '---------------------------------------------------------------------',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.black)),

                pw.Text(
                  'THANK YOU !',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.normal),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'WIFI : 1234567890',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.normal),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/recette_commande.pdf';
    final File file = File(tempPath);
    await file.writeAsBytes(await pdf.save());
    pdfFilePath = tempPath;
    final pageNumber = 1;

    _cartItems.clear();
    _selectedCartItem = null;
    _cartTotal = "0.0";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF enregistré avec succès."),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _goToPreviousCategoryPage() {
    setState(() {
      if (_currentCategoryPage > 0) {
        _currentCategoryPage--;
      }
    });
  }

  void _goToNextCategoryPage() {
    setState(() {
      if ((_currentCategoryPage + 1) * _categoriesPerPage <
          _categories.length) {
        _currentCategoryPage++;
      }
    });
  }

  void _removeFromCartFromBottom() {
    if (_cartItems.isNotEmpty) {
      setState(() {
        _cartItems.removeLast();
        _updateTotal();
      });
    }
  }

  void searchByBarcodeOrReference(String value) {
    setState(() {
      _selectedCategoryArticles = _articleService
          .getArticlesByCategory(_selectedCategory)
          .where((article) =>
              article.designation.toLowerCase().contains(value.toLowerCase()) ||
              article.codeBarre.toLowerCase().contains(value.toLowerCase()) ||
              article.reference.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });

    if (_selectedCategoryArticles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Résultat de la recherche'),
            content: Text('Aucun article trouvé pour la valeur saisie.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedCategoryArticles = _articleService
                        .getArticlesByCategory(_selectedCategory);
                  });
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _clearInput() {
    setState(() {
      if (_fieldToUpdate == FieldToUpdate.Quantity) {
        String currentText = _quantityInputController.text;
        if (currentText.isNotEmpty) {
          _quantityInputController.text =
              currentText.substring(0, currentText.length - 1);
        }
      } else if (_fieldToUpdate == FieldToUpdate.Price) {
        String currentText = _quantityInputController.text;
        if (currentText.isNotEmpty) {
          _quantityInputController.text =
              currentText.substring(0, currentText.length - 1);
        }
      } else if (_fieldToUpdate == FieldToUpdate.Discount) {
        String currentText = _quantityInputController.text;
        if (currentText.isNotEmpty) {
          _quantityInputController.text =
              currentText.substring(0, currentText.length - 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _quantityInputController.dispose();
    super.dispose();
  }

  Widget _buildNumberButton(String value) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: TextButton(
        onPressed: () {
          setState(() {
            switch (_fieldToUpdate) {
              case FieldToUpdate.Quantity:
                _quantityInputController.text += value;
                break;
              case FieldToUpdate.Price:
                if (!_quantityInputController.text.contains('.') ||
                    value != '.') {
                  _quantityInputController.text += value;
                }
                break;
              case FieldToUpdate.Discount:
                _quantityInputController.text += value;
                break;
            }
          });
        },
        child: Text(
          value,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 25,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black54,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: Colors.black12, width: 1.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
      ),
    );
  }

  void _updateTotal() {
    double newTotal = 0;
    for (CartItem item in _cartItems) {
      double articleTotal = double.parse(item.price) * item.quantity;
      newTotal += articleTotal;
    }
    setState(() {
      _cartTotal = newTotal.toStringAsFixed(2);
    });
  }

  void _fetchArticles(String categoryName) {
    FirebaseFirestore.instance
        .collection('articles')
        .where('categorie', isEqualTo: categoryName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> fetchedArticles =
          []; // Liste temporaire pour les articles récupérés
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic>? data =
            document.data() as Map<String, dynamic>?; // Vérification de type
        if (data != null) {
          fetchedArticles.add(data);
        }
      }
      setState(() {
        _articles = fetchedArticles;
      });
    }).catchError((error) {
      print("Erreur lors de la récupération des articles: $error");
    });
  }

  Widget _buildArticleButton(Map<String, dynamic> categorieData, int index) {
    String categorieName = categorieData['name'] ?? '';
    return ElevatedButton(
      onPressed: () {
        _fetchArticles(categorieData['name']);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text(
              categorieName.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.only(top: 2.0),
          //   child: categorieData['imageUrl'] != null && categorieData['imageUrl'].isNotEmpty
          //       ? Image.network(
          //     categorieData['imageUrl'],
          //     height: 50,
          //     width: 50,
          //   )
          //       : Icon(Icons.error
          //   ),
          // ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black12, width: 1.0),
        ),
        minimumSize: Size(40, 40),
      ),
    );
  }

  Widget _buildArticleButtonnnnnnn(Map<String, dynamic> articleData) {
    String designation = articleData['designation'] ?? '';
    return ElevatedButton(
      onPressed: () {
        _addToCart(articleData);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            designation.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black12, width: 1.0),
        ),
        minimumSize: Size(100, 60), // Largeur et hauteur du bouton
      ),
    );
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _goToNextPage() {
    setState(() {
      if (_currentPage < _totalPages - 1) {
        _currentPage++;
      }
    });
  }

  void addToCart(Article article) {
    bool itemExists = false;
    for (CartItem cartItem in _cartItems) {
      if (cartItem.title == article.designation) {
        itemExists = true;
        print(
            'Existing item: ${cartItem.title}, Quantity: ${cartItem.quantity}');
        cartItem.quantity += 1;
        break;
      }
    }

    if (!itemExists) {
      print('New item added: ${article.designation}');
      setState(() {
        _cartItems.add(CartItem(
          title: article.designation,
          price: article.prix,
          quantity: 1,
        ));
      });
    }
    _updateTotal();
  }

  void _removeFromCart(CartItem cartItem) {
    setState(() {
      _cartItems.remove(cartItem); // Supprimer l'article du panier
      calculerTotalTTC(); // Recalculer le total TTC après la suppression de l'article
    });
  }
}
