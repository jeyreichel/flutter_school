import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('categories');

  Future<QuerySnapshot<Object?>> getAll() async {
    return await collection.get();
  }

  Future<List<String>> getNames() async {
    final querySnapshot = await getAll();
    return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<List<String>> getIds() async {
    final querySnapshot = await getAll();
    return querySnapshot.docs.map((doc) => doc['ids'] as String).toList();
  }
}
