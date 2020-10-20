import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class CategoryService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'categories';

  void createCategory(String name) async {
    var id = Uuid();
    String categoryId = id.v1();
    try {
      await _firestore.collection(ref).doc(categoryId).set({'category': name});
    } catch (e, s) {
      print(s);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<List<DocumentSnapshot>> getCategories() async =>
      await _firestore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) async =>
      await _firestore
          .collection(ref)
          .where('category', isEqualTo: suggestion)
          .get()
          .then((snap) {
        return snap.docs;
      });
}
