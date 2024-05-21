import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('articles');

  Future<QuerySnapshot<Object?>> getAll() async {
    return await collection.get();
  }

  Future<List> getProducts() async {
    final querySnapshot = await getAll();
    return querySnapshot.docs
        .map((doc) => {"id": doc['id'], "category": doc['categorie']})
        .toList();
  }
}
