import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('commandes');

  Future<QuerySnapshot<Object?>> getAll() async {
    return await collection.get();
  }

  Future<List<String>> getDates() async {
    final querySnapshot = await getAll();
    return querySnapshot.docs
        .map((doc) =>
            (doc['date'] as Timestamp).toDate().toString().substring(0, 10))
        .toList();
  }
}
