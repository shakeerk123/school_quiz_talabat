import 'package:back_to_school/utils/widgets/bounce_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loginAsParent(BuildContext context) async {
    DocumentReference sessionRef =
        FirebaseFirestore.instance.collection('sessions').doc('currentSession');
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    if (sessionSnapshot.exists && sessionSnapshot['isParentLoggedIn'] == true) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Parent is already logged in on another device.')));
    } else {
      await sessionRef.update({'isParentLoggedIn': true});
      Get.toNamed('/waiting', arguments: 'parent');
    }
  }

  Future<void> _loginAsKid(BuildContext context) async {
    DocumentReference sessionRef =
        FirebaseFirestore.instance.collection('sessions').doc('currentSession');
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    if (sessionSnapshot.exists && sessionSnapshot['isKidLoggedIn'] == true) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kid is already logged in on another device.')));
    } else {
      await sessionRef.update({'isKidLoggedIn': true});
      Get.toNamed('/waiting', arguments: 'kid');
    }
  }

  Future<void> _resetDatabase() async {
    DocumentReference sessionRef =
        FirebaseFirestore.instance.collection('sessions').doc('currentSession');
    await sessionRef.update({
      'parentCurrentQuestionIndex': 0,
      'kidMatchedScore': 0,
      'parentMatchedScore': 0,
      'childCurrentQuestionIndex': 0,
      'parentAnswers': [],
      'childAnswers': [],
      'parentSubmittedAnswer': null,
      'childSubmittedAnswer': null,
      'parentCompleted': false,
      'kidCompleted': false,
      'isParentLoggedIn': false,
      'isKidLoggedIn': false,
      'parentReady': false,
      'kidReady': false,
      'playAgain': false, // Reset th
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFA629), // Set background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _resetDatabase();
              },
              child: const Text('Reset Database and Go to Role Selection'),
            ),
            const Text(
              'Welcome\nBack 2 School',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(20),
              children: [
                BouncingButton(
                  onTap: () => _loginAsParent(context),
                  text: 'Dad',
                ),
                BouncingButton(
                  onTap: () => _loginAsParent(context),
                  text: 'Mom',
                ),
                BouncingButton(
                  onTap: () => _loginAsKid(context),
                  text: 'Boy',
                ),
                BouncingButton(
                  onTap: () => _loginAsKid(context),
                  text: 'Girl',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
