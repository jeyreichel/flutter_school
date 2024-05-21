import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../../models/categorie.dart';
import '../../services/article_service.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeCategorie extends StatefulWidget {
  @override
  _ListeCategorieState createState() => _ListeCategorieState();
}

class _ListeCategorieState extends State<ListeCategorie> {
  late CategorieService _categorieService;
  late List<Categorie> _originalCategories;
  late List<Categorie> _filteredCategories;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  bool _isNameEmpty = false;
  String _nomSearchText = '';
  bool isListVisible = true;
  bool _isFiltered = false;
  String _searchName = '';
  String _searchReference = '';
  String _selectedCategory = '';
  List<String> _categories = [];
  bool _isEditVisible = false;
  File? imageFile;
  bool hasSelectedImage = false;
  bool isLoading = false;
  Categorie? _selectedCategorie;

  @override
  void initState() {
    super.initState();
    _categorieService =
        CategorieService(); // Initialize _categorieService first
    _originalCategories = _categorieService.getCategories();
    _filteredCategories = List.from(_originalCategories);
    _categories = _categorieService
        .getCategories()
        .map((category) => category.name)
        .toList();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories[0];
    }
    // Ajoutez le gestionnaire d'événements Caps Lock ici
    RawKeyboard.instance.addListener((RawKeyEvent event) {
      if (event is RawKeyDownEvent &&
          event.logicalKey.keyId == LogicalKeyboardKey.capsLock.keyId) {
        // Gérer l'événement Caps Lock ici
        print('Caps Lock est activé');
      }
    });
  }

  Future<void> addCategory(String name, String reference) async {
    try {
      // Référence à la collection "categories" dans Firestore
      CollectionReference categories =
          FirebaseFirestore.instance.collection('categories');

      // Ajouter un nouveau document avec un ID généré automatiquement
      DocumentReference docRef = await categories.add({
        'name': name,
        'reference': reference,
      });

      // Obtenir l'ID généré par Firestore et mettre à jour le document avec cet ID
      await docRef.update({'id': docRef.id});

      print('Catégorie ajoutée avec succès !');
    } catch (e) {
      print('Erreur lors de l\'ajout de la catégorie : $e');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = basename(imageFile.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);

      // Télécharger l'image dans Firebase Storage
      await storageReference.putFile(imageFile);

      // Obtenir l'URL de téléchargement de l'image
      String imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return ''; // Retourner une chaîne vide en cas d'erreur
    }
  }

  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        hasSelectedImage = true;
      });
    }
  }

  void updateCategorie(Categorie updateCategorie) {
    setState(() {
      int index = _originalCategories.indexWhere(
          (article) => article.reference == updateCategorie.reference);

      if (index != -1) {
        _originalCategories[index] = updateCategorie;

        // Update the _filteredArticles list as well
        int filteredIndex = _filteredCategories.indexWhere(
            (article) => article.reference == updateCategorie.reference);

        if (filteredIndex != -1) {
          _filteredCategories[filteredIndex] = updateCategorie;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isListVisible && !_isEditVisible,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par nom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchName = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Visibility(
                visible: isListVisible && !_isEditVisible,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par référence',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchReference = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Spacer(),
              //////////////////////Retour à la liste fi edit
              if (_isEditVisible)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategorie = null;
                      _isEditVisible = false;
                    });
                  },
                  icon: Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Retour à la liste',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF067487),
                    minimumSize: Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFF067487), width: 1.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                ),
              Visibility(
                visible: !isListVisible,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      // Utilisez le contexte de MaterialApp ou Scaffold
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content:
                              Text('Voulez-vous enregistrer cette catégorie ?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                String name = _nameController.text;
                                String reference = _referenceController.text;
                                addCategory(name, reference);
                                await _loadCategories();
                                Navigator.of(context).pop();
                                await Future.delayed(Duration(
                                    seconds:
                                        2)); // Simulation d'une opération asynchrone

                                setState(() {
                                  isLoading =
                                      false; // Masquer l'indicateur de chargement
                                });

                                // Réinitialiser les champs après l'ajout de la catégorie
                                _nameController.clear();
                                _referenceController.clear();
                              },
                              child: Text('Enregistrer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text('Enregistrer',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.green, width: 1.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              /////////////////////////////////::isListVisible ? 'Nouvelle categorie ' : 'Retour à la liste',
              if (!_isEditVisible)
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
                    isListVisible ? 'Nouvelle catégorie ' : 'Retour à la liste',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF067487),
                    minimumSize: Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFF067487), width: 1.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                ),
              SizedBox(width: 5),

              ////////////////////::Enregistrer modifications
              if (_isEditVisible)
                ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedCategorie != null) {
                      updateCategorie(
                          _selectedCategorie!); // Update the catg in the list
                      setState(() {
                        _selectedCategorie = null;
                        _isEditVisible = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Enregistrer modifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.green, width: 1.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                ),
            ],
          ),
        ),
        body: isListVisible
            ? Card(
                color: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isEditVisible)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categories')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columnSpacing: 250.0,
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
                                DataColumn(label: Text('Référence')),
                                DataColumn(label: Text('Nom')),
                                //DataColumn(label: Text('Image')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: snapshot.data!.docs.where((document) {
                                Map<String, dynamic>? data =
                                    document.data() as Map<String, dynamic>?;
                                String name = data!['name'] ?? '';
                                String reference = data['reference'] ?? '';
                                return name
                                        .toLowerCase()
                                        .contains(_searchName.toLowerCase()) &&
                                    reference.toLowerCase().contains(
                                        _searchReference.toLowerCase());
                              }).map((QueryDocumentSnapshot document) {
                                Map<String, dynamic>? data =
                                    document.data() as Map<String, dynamic>?;
                                String name = data!['name'] ?? '';
                                String reference = data['reference'] ?? '';
                                String imageUrl = data['imageUrl'] ?? '';
                                return DataRow(
                                  color:
                                      MaterialStateColor.resolveWith((states) {
                                    return snapshot.data!.docs
                                                    .indexOf(document) %
                                                2 ==
                                            0
                                        ? Colors.white
                                        : Colors.black12;
                                  }),
                                  cells: [
                                    DataCell(Text(reference)),
                                    DataCell(Text(name)),
                                    // DataCell(
                                    //   imageUrl.isNotEmpty
                                    //       ? Image.network(imageUrl)
                                    //       : Icon(Icons.error),
                                    // ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Modifier la catégorie'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  _nameController,
                                                              decoration:
                                                                  InputDecoration(
                                                                      labelText:
                                                                          'Nom'),
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  _referenceController,
                                                              decoration:
                                                                  InputDecoration(
                                                                      labelText:
                                                                          'Référence'),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            // Espacement
                                                            // Row(
                                                            //   children: [
                                                            //     imageUrl.isNotEmpty
                                                            //         ? Image.network(imageUrl, width: 100, height: 100)
                                                            //         : Icon(Icons.error),
                                                            //     ElevatedButton(
                                                            //       onPressed: () {
                                                            //        },
                                                            //       child: Text('Sélectionner l\'image'),
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                Text('Annuler'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              modifyCategory(
                                                                  document.id);
                                                              setState(() {
                                                                _nameController
                                                                    .clear();
                                                                _referenceController
                                                                    .clear();
                                                                //imageUrl = '';
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                                'Modifier'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Confirmation'),
                                                    content: Text(
                                                        'Voulez-vous vraiment supprimer cette catégorie ?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Annuler'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteCategory(document
                                                              .id); // Supprimer la catégorie
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            Text('Supprimer'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    if (_selectedCategorie != null)
                      Container(
                        width: 500,
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: 500),
                              child: Expanded(
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Modifier Categorie',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      TextFormField(
                                        initialValue: _selectedCategorie!.name,
                                        decoration: InputDecoration(
                                          labelText: 'Référence',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategorie!.name = value;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: _selectedCategorie!.name,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategorie!.name =
                                                value.toString();
                                          });
                                        },
                                        items: _categories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category,
                                            child: Text(category),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Catégorie',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                child: isLoading
                    ? CircularProgressIndicator() // Indicateur de chargement circulaire
                    : Row(
                        children: [
                          SizedBox(
                            width: 25,
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 500),
                            child: Expanded(
                                child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ajouter un nouvelle categorie",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'nom',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: _referenceController,
                                    decoration: InputDecoration(
                                      labelText: 'Référence',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  // DropdownButtonFormField<String>(
                                  //   value: _selectedCategory,
                                  //   onChanged: (newValue) {
                                  //     setState(() {
                                  //       _selectedCategory = newValue!;
                                  //     });
                                  //   },
                                  //   items: _categories.map((category) {
                                  //     return DropdownMenuItem<String>(
                                  //       value: category,
                                  //       child: Text(category),
                                  //     );
                                  //   }).toList(),
                                  //   decoration: InputDecoration(
                                  //     labelText: 'Catégorie',
                                  //     border: OutlineInputBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            )),
                          ),
                        ],
                      ),
              ));
  }

// Fonction pour modifier la catégorie dans Firestore
  void modifyCategory(String categoryId) {
    String newName = _nameController.text.trim();
    String newReference = _referenceController.text.trim();

    // Mettez à jour la catégorie dans Firestore avec les nouvelles valeurs
    FirebaseFirestore.instance.collection('categories').doc(categoryId).update({
      'name': newName,
      'reference': newReference,
      // Si vous avez besoin de mettre à jour l'image aussi, ajoutez 'imageUrl': nouvelleUrlImage,
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .delete();
      print('Catégorie supprimée avec succès !');
    } catch (e) {
      print('Erreur lors de la suppression de la catégorie : $e');
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true; // Afficher l'indicateur de chargement
    });

// Charger les catégories depuis Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<Map<String, dynamic>> categoriesData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

// Extraire les noms des catégories
    List<String> categories =
        categoriesData.map((data) => data['name'] as String).toList();

    setState(() {
      isLoading = false; // Masquer l'indicateur de chargement
      _categories = categories;
    });
  }

  void modifyImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        hasSelectedImage = true;
      });
    }
  }

  void _searchCategories({String reference = '', String nom = ''}) {
    reference = reference.toLowerCase(); // Convert search query to lowercase
    nom = nom.toLowerCase(); // Convert search query to lowercase

    _filteredCategories = _originalCategories.where((categorie) {
      bool matchReference = reference.isEmpty ||
          categorie.reference.toLowerCase().contains(reference);
      bool matchNom = nom.isEmpty || categorie.name.toLowerCase().contains(nom);
      return matchReference && matchNom;
    }).toList();

    setState(() {
      _isFiltered = true;
      _nomSearchText = nom;
    });
  }

  void _resetSearch() {
    setState(() {
      _filteredCategories = List.from(_originalCategories);
      _isFiltered = false;
    });
  }
}
