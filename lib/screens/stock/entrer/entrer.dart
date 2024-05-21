import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:path/path.dart' as
 path;
import '../../../models/entrer_stock.dart';
import '../../../services/StockEntryReceipt.dart';
import '../../../services/article_service.dart';
import '../../../models/article.dart';
import 'package:intl/date_symbol_data_local.dart';

class EntrerPage extends StatefulWidget {
  @override
  _EntrerPage createState() => _EntrerPage();
}

class _EntrerPage extends State<EntrerPage> {
  bool isLoading = false;
  String _searchReference = '';
  String _searchDesignation = '';
  String selectedCategory = '';
  String? _selectedCategory;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _codeBarreController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool isListVisible = true;
  List<String> categoryNames = [];
  Article? _selectedArticle;
  bool _isEditVisible = false;
  bool hasSelectedImage = false;

  bool areFieldsEmpty() {
    return _referenceController.text.isEmpty ||
        _codeBarreController.text.isEmpty ||
        _designationController.text.isEmpty ||
        _selectedCategory == null ||
        _stockController.text.isEmpty ||
        _prixController.text.isEmpty ||
        imageFile == null;
  }

  File? imageFile;

  @override
  void initState() {
    super.initState();
    getCategoryNames();
  }

  Future<void> addArticle(
      String designation,
      String reference,
      String codeABarre,
      String categorie,
      String prix,
      String stock,
      File? image,
      ) async {
    try {
      setState(() {
        isLoading = true;
      });
      // Référence à la collection "articles" dans Firestore
      CollectionReference articles =
      FirebaseFirestore.instance.collection('articles');

      // Télécharger l'image dans Firebase Storage
      String imageUrl = '';
      if (image != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('article_images')
            .child(reference);
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Ajouter un nouveau document avec un ID généré automatiquement
      DocumentReference docRef = await articles.add({
        'designation': designation,
        'reference': reference,
        'code a barre': codeABarre,
        'categorie': categorie,
        'stock': stock,
        'prix': prix,
        'image_url': imageUrl,
      });

      // Obtenir l'ID généré par Firestore et mettre à jour le document avec cet ID
      await docRef.update({'id': docRef.id});

      print('Article ajouté avec succès !');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'article : $e');
      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ///////////////::Rechercher par référence
            if (!_isEditVisible)
              Visibility(
                visible: isListVisible,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: SizedBox(
                    width: 200,
                    height: 45,
                    child:TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par référence',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchReference = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
              ),
            /////////////////::::::Rechercher par designation
            if (!_isEditVisible)
              Visibility(
                visible: isListVisible,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: SizedBox(
                    width: 200,
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par désignation',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchDesignation = value.toLowerCase();
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
                    _selectedArticle = null;
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
            /////////////////////////////////::isListVisible ? 'Nouvelle article ' : 'Retour à la liste',
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
                  isListVisible ? 'Nouvelle article ' : 'Retour à la liste',
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
            SizedBox(width: 8),
            ////////////////////::Enregistrer modifications
            if (_isEditVisible)
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.save,
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
            SizedBox(width: 8),
            /////////////::Enregistrerfi add article
            if (!_isEditVisible)
              Visibility(
                visible: !isListVisible,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (areFieldsEmpty()) {
                      // Afficher un AwesomeDialog d'erreur ici
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Erreur'),
                            content: Text(
                                'Veuillez remplir tous les champs avant d\'enregistrer.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text(
                                'Voulez-vous vraiment enregistrer cet article ?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Enregistrer'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        try {
                          String ref = _referenceController.text;
                          String codeabarre = _codeBarreController.text;
                          String designation =
                              _designationController.text;
                          String? catg = _selectedCategory;
                          String stock = _stockController.text;
                          String prix = _prixController.text;

                          // Appeler la fonction addArticle avec l'objet File
                          await addArticle(designation,ref, codeabarre,
                              catg.toString(), prix,stock,  imageFile);
                          // Si l'ajout est réussi, arrêtez l'indicateur de chargement et réinitialisez les champs
                          setState(() {
                            _referenceController.clear();
                            _codeBarreController.clear();
                            _designationController.clear();
                            _stockController.clear();
                            _prixController.clear();
                            imageFile = null;
                            _selectedCategory == null;
                            isLoading = false;
                          });
                        } catch (e) {
                          // Gérer les erreurs ici
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
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
                    .collection('articles')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var filteredArticles = snapshot.data!.docs.where((article) {
                    var data = article.data() as Map<String, dynamic>;
                    String reference = data['reference']?.toLowerCase() ?? '';
                    String designation = data['designation']?.toLowerCase() ?? '';
                    return reference.contains(_searchReference) &&
                        designation.contains(_searchDesignation);
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
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Référence')),
                        DataColumn(label: Text('Catégorie')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('prix')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows:filteredArticles.map((QueryDocumentSnapshot document) {
                        Map<String, dynamic>? data =
                        document.data() as Map<String, dynamic>?;
                        String codeAbarre = data!['code a barre'] ?? '';
                        String name = data!['designation'] ?? '';
                        String categorie = data!['categorie'] ?? '';
                        String reference = data['reference'] ?? '';
                        String prix = data['prix'] ?? '';
                        String stock = data['stock'] ?? '';
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return snapshot.data!.docs.indexOf(document) %
                                2 ==
                                0
                                ? Colors.white
                                : Colors.black12;
                          }),
                          cells: [
                            DataCell(Text(codeAbarre)),
                            DataCell(Text(reference)),
                            DataCell(Text(categorie)),
                            DataCell(Text(name)),
                            DataCell(Text('$prix DT')),
                            DataCell(Text(stock)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      editArticleDialog(context, document);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmation de suppression'),
                                            content: Text('Voulez-vous vraiment supprimer cet article ?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(false); // Annuler la suppression
                                                },
                                                child: Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Confirmer la suppression
                                                },
                                                child: Text('Supprimer'),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((confirmed) {
                                        if (confirmed == true) {
                                          deleteArticle(document.id);
                                        }
                                      });
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
            if (_selectedArticle != null)
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Modifier Article',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 25,
                              ),
                              TextFormField(
                                initialValue: _selectedArticle!.reference,
                                decoration: InputDecoration(
                                  labelText: 'Référence',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedArticle!.reference = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                initialValue: _selectedArticle!.codeBarre,
                                decoration: InputDecoration(
                                  labelText: 'Code à barre',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedArticle!.codeBarre = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                initialValue:
                                _selectedArticle!.designation,
                                decoration: InputDecoration(
                                  labelText: 'Designation',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedArticle!.designation = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value ?? '';
                                  });
                                },
                                items: categoryNames.map((category) {
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
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                initialValue:
                                _selectedArticle!.stock.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Stock',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedArticle!.stock =value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                initialValue:
                                _selectedArticle!.prix.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Prix',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedArticle!.prix =value;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 3,
                      width: 100,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 25),
                        Container(
                          height: 250,
                          width: 500,
                          color: Colors.grey[200],
                          child: imageFile != null
                              ? Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          )
                              : Center(
                            child: Text(
                              "Aucune image sélectionnée",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: hasSelectedImage
                              ? modifyImage
                              : selectImage,
                          child: Text(hasSelectedImage
                              ? 'Modifier l\'image'
                              : 'Sélectionner une image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 1.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        if (hasSelectedImage)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                imageFile = null;
                                hasSelectedImage = false;
                              });
                            },
                            child: Text('Annuler l\'image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                    color: Colors.red, width: 1.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      )
          : Container(
          width: double.infinity,
          child: Row(
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
                            "Ajouter un nouvelle article",
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
                            controller: _referenceController,
                            decoration: InputDecoration(
                              labelText: 'Référence',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: _codeBarreController,
                            decoration: InputDecoration(
                              labelText: 'Code à barre',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                                print('_selectedCategory $_selectedCategory');
                              });
                            },
                            items: categoryNames
                                .map<DropdownMenuItem<String>>((String value) {
                              print('categoryNames $categoryNames');
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Catégorie',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: _prixController,
                            decoration: InputDecoration(
                              labelText: 'Prix',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: _designationController,
                            decoration: InputDecoration(
                              labelText: 'Désignation',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(
                width: 100,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    height: 250,
                    width: 500,
                    color: Colors.grey[200],
                    child: imageFile != null
                        ? Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    )
                        : Center(
                      child: Text(
                        "Aucune image sélectionnée",
                        style: TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: hasSelectedImage ? modifyImage : selectImage,
                    child: Text(hasSelectedImage
                        ? 'Modifier l\'image'
                        : 'Sélectionner une image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: Colors.blueAccent, width: 1.0),
                      ),
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  if (hasSelectedImage)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageFile = null;
                          hasSelectedImage = false;
                        });
                      },
                      child: Text('Annuler l\'image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.red, width: 1.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                      ),
                    ),
                ],
              ),
            ],
          )),
    );
  }
  void editArticleDialog(BuildContext context, QueryDocumentSnapshot articleSnapshot) {
    Map<String, dynamic>? articleData = articleSnapshot.data() as Map<String, dynamic>?;

    if (articleData == null) {
      // Handle null data if needed
      return;
    }

    String reference = articleData['reference'] ?? '';
    String designation = articleData['designation'] ?? '';
    String categorie = articleData['categorie'] ?? '';
    String prix = articleData['prix'] ?? '';
    String code_a_barre = articleData['code a barre'] ?? '';
    String stock = articleData['stock'] ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Modifier Article'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: reference,
                    decoration: InputDecoration(labelText: 'Référence'),
                    onChanged: (value) {
                      reference = value;
                    },
                  ),
                  TextFormField(
                    initialValue: code_a_barre,
                    decoration: InputDecoration(labelText: 'Code à barre'),
                    onChanged: (value) {
                      code_a_barre = value;
                    },
                  ),
                  TextFormField(
                    initialValue: designation,
                    decoration: InputDecoration(labelText: 'Designation'),
                    onChanged: (value) {
                      designation = value;
                    },
                  ),
                  TextFormField(
                    initialValue: categorie,
                    decoration: InputDecoration(labelText: 'Catégorie'),
                    onChanged: (value) {
                      categorie = value;
                    },
                  ),
                  TextFormField(
                    initialValue: prix,
                    decoration: InputDecoration(labelText: 'Prix'),
                    onChanged: (value) {
                      prix = value;
                    },
                  ),
                  TextFormField(
                    initialValue: stock,
                    decoration: InputDecoration(labelText: 'Stock'),
                    onChanged: (value) {
                      stock = value;
                    },
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
                    // Save the updated data back to Firestore
                    FirebaseFirestore.instance.collection('articles').doc(articleSnapshot.id).update({
                      'reference': reference,
                      'designation': designation,
                      'categorie': categorie,
                      'prix': prix,
                      'code a barre': code_a_barre,
                      'stock': stock,
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Modifier'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> getCategoryNames() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();

      setState(() {
        categoryNames =
            querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
      print('categoryNames $categoryNames');
    } catch (e) {
      print('Error fetching category names: $e');
    }
  }


  Future<void> deleteArticle(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('articles')
          .doc(categoryId)
          .delete();
      print('Catégorie supprimée avec succès !');
    } catch (e) {
      print('Erreur lors de la suppression de la catégorie : $e');
    }
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
}
