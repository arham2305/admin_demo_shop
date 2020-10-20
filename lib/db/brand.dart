import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BrandService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'brands';

  void createBrand(String name) async {
    var id = Uuid();
    String brandId = id.v1();

    await _firestore.collection(ref).doc(brandId).set({'brand': name});
  }

  Future<List<DocumentSnapshot>> getBrands() async =>
      await _firestore.collection(ref).get().then((snaps) {
//        print(snaps.docs.length);
        return snaps.docs;
      });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) async =>
      await _firestore
          .collection(ref)
          .where('brand', isEqualTo: suggestion)
          .get()
          .then((snap) {
        return snap.docs;
      });
}
