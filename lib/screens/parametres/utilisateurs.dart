import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import 'ajouter_utilisateur.dart';
import 'modifier_utilisateur.dart';

class ListeUser extends StatefulWidget {
  @override
  _ListeUserState createState() => _ListeUserState();
}

class _ListeUserState extends State<ListeUser> {
  String _searchnom = '';
  String _searchIdentifiant = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher par nom',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchnom = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher par ID',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchIdentifiant = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
            IconButton(
              icon: Icon(Icons.add, color: Colors.black,size: 35,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddUserPage(),
                  ),
                );

              },
            ),
        ),
          ],
        ),
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 150.0,
              dataRowHeight: 48.0,
              headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Color(0xFF067487),
              ),
              headingTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dividerThickness: 1.0,
              columns: [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Prénom')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Action')),
              ],
              rows: snapshot.data!.docs.where((document) {
                Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                String name = data!['nom'] ?? '';
                String identifiant = data['identifiant'] ?? '';
                return name.toLowerCase().contains(_searchnom.toLowerCase()) &&
                    identifiant.toLowerCase().contains(_searchIdentifiant.toLowerCase());
              }).map((QueryDocumentSnapshot document){
                Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                String name = data!['nom'] ?? '';
                String prenom = data['prenom'] ?? '';
                String role = data['role'] ?? '';
                String id = data['identifiant'] ?? '';
                String email = data['email'] ?? '';
                return DataRow(
                  color: MaterialStateColor.resolveWith((states) {
                    return snapshot.data!.docs.indexOf(document) % 2 == 0
                        ? Colors.white
                        : Colors.black12;
                  }),
                  cells: [
                    DataCell(Text(name)),
                    DataCell(Text(prenom)),
                    DataCell(Text(role)),
                    DataCell(Text(email)),
                    DataCell(Text(id)),
                    // DataCell(
                    //   imageUrl.isNotEmpty
                    //       ? Image.network(imageUrl)
                    //       : Icon(Icons.error),
                    // ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              editUserDialog(context, document);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmation de suppression'),
                                    content: Text('Voulez-vous vraiment supprimer ce utilisateur ?'),
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
                                  deleteUser(document.id);
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

    );
  }
  Future<void> deleteUser(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(categoryId)
          .delete();
      print('user supprimée avec succès !');
    } catch (e) {
      print('Erreur lors de la suppression de la user : $e');
    }
  }
  void editUserDialog(BuildContext context, QueryDocumentSnapshot articleSnapshot) {
    Map<String, dynamic>? articleData = articleSnapshot.data() as Map<String, dynamic>?;

    if (articleData == null) {
      // Handle null data if needed
      return;
    }

    String nom = articleData['nom'] ?? '';
    String prenom = articleData['prenom'] ?? '';
    String email = articleData['email'] ?? '';
    String identifiant = articleData['identifiant'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Modifier Utilisateur'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: nom,
                    decoration: InputDecoration(labelText: 'Nom'),
                    onChanged: (value) {
                      nom = value;
                    },
                  ),
                  TextFormField(
                    initialValue: prenom,
                    decoration: InputDecoration(labelText: 'Prenom'),
                    onChanged: (value) {
                      prenom = value;
                    },
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  TextFormField(
                    initialValue: identifiant,
                    decoration: InputDecoration(labelText: 'Identifiant'),
                    onChanged: (value) {
                      identifiant = value;
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
                    FirebaseFirestore.instance.collection('users').doc(articleSnapshot.id).update({
                      'nom': nom,
                      'prenom': prenom,
                      'email': email,
                      'identifiant': identifiant,
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

}
