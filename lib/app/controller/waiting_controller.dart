import 'dart:async';
import 'package:back_to_school/app/view/game_screen.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class WaitingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _sessionRef;
  var isReady = false.obs;
  late StreamSubscription<DocumentSnapshot> _subscription;
  String role = '';

  @override
  void onInit() {
    super.onInit();
    role = Get.arguments;
    _sessionRef = _firestore.collection('sessions').doc('currentSession');
    _subscription = _sessionRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final parentReady = data['parentReady'] ?? false;
        final kidReady = data['kidReady'] ?? false;
if (parentReady && kidReady) {
  Get.offAll(() => GameScreen(role: role));
}


      }
    });
  }

  Future<void> setReady() async {
    if (role == 'parent') {
      await _sessionRef.update({'parentReady': true});
    } else {
      await _sessionRef.update({'kidReady': true});
    }
    isReady.value = true;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
