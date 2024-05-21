import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('caisses');

  Future<QuerySnapshot<Object?>> getAll() async {
    return await collection.get();
  }

  Future<List> getItems() async {
    final querySnapshot = await getAll();
    return querySnapshot.docs
        .map((doc) =>
            {"id": doc['IdCaisse'], "orders": doc['commandes'] as List})
        .toList();
  }
}
