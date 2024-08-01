import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isParentLoggedIn = false.obs;
  var isKidLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    DocumentReference sessionRef = _firestore.collection('sessions').doc('currentSession');
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    if (sessionSnapshot.exists) {
      isParentLoggedIn.value = sessionSnapshot['isParentLoggedIn'] ?? false;
      isKidLoggedIn.value = sessionSnapshot['isKidLoggedIn'] ?? false;
    }
  }

  Future<void> loginAsParent() async {
    DocumentReference sessionRef = _firestore.collection('sessions').doc('currentSession');
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    if (sessionSnapshot.exists && sessionSnapshot['isParentLoggedIn'] == true) {
      Get.snackbar('Error', 'Parent is already logged in on another device.');
    } else {
      await sessionRef.update({'isParentLoggedIn': true});
      Get.toNamed('/waiting', arguments: 'parent');
    }
  }

  Future<void> loginAsKid() async {
    DocumentReference sessionRef = _firestore.collection('sessions').doc('currentSession');
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    if (sessionSnapshot.exists && sessionSnapshot['isKidLoggedIn'] == true) {
      Get.snackbar('Error', 'Kid is already logged in on another device.');
    } else {
      await sessionRef.update({'isKidLoggedIn': true});
      Get.toNamed('/waiting', arguments: 'kid');
    }
  }
}
