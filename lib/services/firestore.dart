import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  Future<void> setData({required String path, Map<String, dynamic>?data}) async {
    final DocumentReference<Map<String, dynamic>?> reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data);
  }
  Stream<List<T>> collectionStream<T>({
    required String path,
    required T builder(Map<String, dynamic> data),
  }) {
    final reference =FirebaseFirestore.instance.collection(path).orderBy('timestrap');
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        snapshot.docs.reversed.map((snapshot) => builder(snapshot.data())).toList());
  }
}