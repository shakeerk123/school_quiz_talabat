import 'package:back_to_school/app/view/matching_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

import 'special_question_screen.dart';

class PrizeScreen extends StatelessWidget {
  final String role; // 'kid' or 'parent'

  const PrizeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congratulations!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset('assets/confetti.json'),
            const Text(
              '10/10 \nYou matched all questions!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Do you want to participate in the grand prize?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _handleYesTap(context);
                  },
                  child: const Text('Yes'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _handleNoTap(context);
                  },
                  child: const Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleYesTap(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore.collection('specialSession').doc('decision').set({
      'decision': 'yes',
    });

    _firestore
        .collection('specialSession')
        .doc('decision')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['decision'] == 'yes') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialQuestionScreen(role: role),
          ),
        );
      }
    });
  }

  void _handleNoTap(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore.collection('specialSession').doc('decision').set({
      'decision': 'no',
    });

    _firestore
        .collection('specialSession')
        .doc('decision')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['decision'] == 'no') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MatchingScreen()),
        );
      }
    });
  }
}
