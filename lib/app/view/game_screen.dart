import 'package:back_to_school/app/view/matching_screen.dart';
import 'package:back_to_school/app/view/prize_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:percent_indicator/linear_percent_indicator.dart';

class GameScreen extends StatefulWidget {
  final String role; // 'kid' or 'parent'

  const GameScreen({super.key, required this.role});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _sessionRef;
  late StreamSubscription<DocumentSnapshot> _subscription;
  int _currentQuestionIndex = 0;
  String _currentQuestion = '';
  List<String> _options = [];
  bool _loading = true;
  late Timer _timer;
  int _remainingTime = 60;
  bool _hasAnswered = false;
  int _matchedScore = 0;
  bool _showPopup = false;
  bool _isMatch = false;
  bool _waitingForOtherPlayer = false;
  String _selectedOption = '';

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer.cancel();
            // _completeGame();
          }
        });
      }
    });
  }

  Future<void> _initializeSession() async {
    _sessionRef = _firestore.collection('sessions').doc('currentSession');
    _subscription = _sessionRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        try {
          final data = snapshot.data() as Map<String, dynamic>;
          final questions = data['questions'] as List<dynamic>;

          // Handle current question index based on role
          if (widget.role == 'parent') {
            _currentQuestionIndex = data['parentCurrentQuestionIndex'];
            _matchedScore = data['parentMatchedScore'] ?? 0;
          } else {
            _currentQuestionIndex = data['childCurrentQuestionIndex'];
            _matchedScore = data['kidMatchedScore'] ?? 0;
          }

          if (_currentQuestionIndex < questions.length) {
            final question = questions[_currentQuestionIndex];
            if (mounted) {
              setState(() {
                _currentQuestion = widget.role == 'parent'
                    ? question['parentQuestion']
                    : question['kidQuestion'];
                _options = List<String>.from(question['options']);
                _loading = false;
                _hasAnswered = false; // Reset for the new question
                _waitingForOtherPlayer = false; // Reset waiting status
                _selectedOption = ''; // Reset selected option
              });
            }
          } else {
            // ignore: avoid_print
            print(
                'Error: currentQuestionIndex ($_currentQuestionIndex) is out of range for questions array (length: ${questions.length}).');
          }

          // Check if both have completed the game
          final parentCompleted = data['parentCompleted'] ?? false;
          final kidCompleted = data['kidCompleted'] ?? false;
          if (parentCompleted && kidCompleted) {
            _completeGame();
          }

          // Show match/not match popup
          if (data['showPopup'] == true) {
            final parentAnswer = data['parentSubmittedAnswer'];
            final childAnswer = data['childSubmittedAnswer'];
            if (mounted) {
              setState(() {
                _isMatch = parentAnswer == childAnswer;
                _showPopup = true;
              });
            }
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _showPopup = false;
                });
              }
            });
          }
        } catch (e) {
          // ignore: avoid_print
          print('Error processing snapshot data: $e');
        }
      }
    }, onError: (error) {
      // ignore: avoid_print
      print('Error listening to document snapshots: $error');
    });
  }

  Future<void> _submitAnswer(String answer) async {
    if (_hasAnswered) return; // Prevent multiple answers for the same question
    setState(() {
      _hasAnswered = true;
      _selectedOption = answer; // Highlight the selected option
    });

    try {
      DocumentSnapshot snapshot = await _sessionRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>;

      if (widget.role == 'parent') {
        await _sessionRef.update({
          'parentAnswers': FieldValue.arrayUnion([answer]),
          'parentSubmittedAnswer': answer,
        });
      } else {
        await _sessionRef.update({
          'childAnswers': FieldValue.arrayUnion([answer]),
          'childSubmittedAnswer': answer,
        });
      }

      // Check if both have answered
      snapshot = await _sessionRef.get();
      final updatedData = snapshot.data() as Map<String, dynamic>;

      if (updatedData['parentSubmittedAnswer'] != null &&
          updatedData['childSubmittedAnswer'] != null) {
        // Both have answered, check if they match
        final parentAnswer = updatedData['parentSubmittedAnswer'];
        final childAnswer = updatedData['childSubmittedAnswer'];
        if (parentAnswer == childAnswer) {
          setState(() {
            _isMatch = true;
            _matchedScore++;
          });
          await _sessionRef.update({
            'parentMatchedScore': _matchedScore,
            'kidMatchedScore': _matchedScore,
          });
        } else {
          setState(() {
            _isMatch = false;
          });
        }

        // Show match/not match popup on both devices
        await _sessionRef.update({
          'showPopup': true,
        });
        await Future.delayed(const Duration(seconds: 1));
        await _sessionRef.update({
          'showPopup': false,
        });

        // Clear submitted answers and move to next question
        await _sessionRef.update({
          'parentSubmittedAnswer': null,
          'childSubmittedAnswer': null,
          'parentCurrentQuestionIndex': FieldValue.increment(1),
          'childCurrentQuestionIndex': FieldValue.increment(1),
        });

        if (_currentQuestionIndex >= questions.length) {
          await _sessionRef.update({
            'parentCompleted': true,
            'kidCompleted': true,
          });
          _completeGame();
        }
      } else {
        setState(() {
          _waitingForOtherPlayer = true;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error submitting answer: $e');
    }
  }

  void _completeGame() async {
    if (widget.role == 'parent') {
      await _sessionRef.update({
        'parentCompleted': true,
      });
    } else {
      await _sessionRef.update({
        'kidCompleted': true,
      });
    }

    // Check if all questions were matched
    if (_matchedScore == _currentQuestionIndex) {
      // All questions matched, navigate to PrizeScreen
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => PrizeScreen(
                  role: widget.role,
                )),
      );
    } else {
      // Navigate to MatchingScreen
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => MatchingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.role.toUpperCase()} - Question ${_currentQuestionIndex + 1}'),
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.role.toUpperCase()} - Question ${_currentQuestionIndex + 1}'),
        automaticallyImplyLeading: false, // Remove the back button
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  Text(
                    '$_matchedScore match',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearPercentIndicator(
                  lineHeight: 5.0,
                  percent: 1.0 - _remainingTime / 60,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.green,
                  animation: true,
                  animateFromLastPercent: true,
                  alignment: MainAxisAlignment.center,
                ),
                const SizedBox(height: 24),
                Text(_currentQuestion, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _submitAnswer(_options[index]);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: _options[index] == _selectedOption
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: _options[index] == _selectedOption
                              ? Colors.red[100]
                              : Colors.white,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _options[index],
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_waitingForOtherPlayer)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Waiting for the other player...',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                if (_selectedOption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Locked option: $_selectedOption',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          if (_showPopup)
            Center(
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _isMatch ? 'Match!' : 'Not a Match!',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
