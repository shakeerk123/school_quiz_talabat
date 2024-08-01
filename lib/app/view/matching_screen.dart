import 'dart:async';

import 'package:back_to_school/app/view/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class MatchingScreen extends StatefulWidget {
  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _sessionRef;
  late StreamSubscription<DocumentSnapshot> _subscription;
  bool _waitingForOther = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _matches = 0;
  List<String> _parentAnswers = [];
  List<String> _childAnswers = [];

  @override
  void initState() {
    super.initState();
    _sessionRef = _firestore.collection('sessions').doc('currentSession');
    _subscription = _sessionRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final parentCompleted = data['parentCompleted'] ?? false;
        final kidCompleted = data['kidCompleted'] ?? false;

        if (parentCompleted && kidCompleted) {
          _calculateMatches().then((matches) {
            setState(() {
              _matches = matches;
              _parentAnswers = List<String>.from(data['parentAnswers']);
              _childAnswers = List<String>.from(data['childAnswers']);
              _waitingForOther = false;
              _controller.forward(); // Start the animation
            });
          });
        }

        if (data['playAgain'] == true) {
          _resetPlayAgain();
        }
      }
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<int> _calculateMatches() async {
    final sessionSnapshot = await _sessionRef.get();
    final data = sessionSnapshot.data() as Map<String, dynamic>;

    final parentAnswers = List<String>.from(data['parentAnswers']);
    final childAnswers = List<String>.from(data['childAnswers']);

    int matches = 0;
    int maxIndex = parentAnswers.length < childAnswers.length
        ? parentAnswers.length
        : childAnswers.length;
    for (int i = 0; i < maxIndex; i++) {
      if (parentAnswers[i] == childAnswers[i]) {
        matches++;
      }
    }

    return matches;
  }

  Future<void> _resetPlayAgain() async {
    await _sessionRef.update({'playAgain': false});
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> _triggerPlayAgain() async {
    await _resetDatabase();
    await _sessionRef.update({'playAgain': true});
  }

  Future<void> _resetDatabase() async {
    await _sessionRef.update({
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
      'playAgain': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Database has been reset')),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForOther) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Waiting for the other player'),
            automaticallyImplyLeading: false),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Matches'), automaticallyImplyLeading: false),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset('assets/confetti.json'),
                Text('Matches: $_matches',
                    style:
                        TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _triggerPlayAgain,
                  child: Text('Play Again'),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
