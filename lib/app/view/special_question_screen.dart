import 'package:back_to_school/app/view/winorlose_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:percent_indicator/linear_percent_indicator.dart';


class SpecialQuestionScreen extends StatefulWidget {
  final String role; // 'kid' or 'parent'

  const SpecialQuestionScreen({super.key, required this.role});

  @override
  _SpecialQuestionScreenState createState() => _SpecialQuestionScreenState();
}

class _SpecialQuestionScreenState extends State<SpecialQuestionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _sessionRef;
  late StreamSubscription<DocumentSnapshot> _subscription;
  String _currentQuestion = '';
  List<String> _options = [];
  bool _loading = true;
  late Timer _timer;
  int _remainingTime = 8;
  bool _hasAnswered = false;
  bool _isMatch = false;
  bool _waitingForOtherPlayer = false;
  String _selectedOption = '';
  bool _showPopup = false;

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
            _moveToWinOrLoseScreen(); // Move to win/lose screen if time runs out
          }
        });
      }
    });
  }

  Future<void> _initializeSession() async {
    _sessionRef = _firestore.collection('specialSession').doc('specialQuestion');
    _subscription = _sessionRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        try {
          final data = snapshot.data() as Map<String, dynamic>;
          final question = widget.role == 'parent' ? data['parentQuestion'] : data['kidQuestion'];
          final options = data['options'] as List<dynamic>;

          if (mounted) {
            setState(() {
              _currentQuestion = question;
              _options = List<String>.from(options);
              _loading = false;
              _hasAnswered = false; // Reset for the new question
              _waitingForOtherPlayer = false; // Reset waiting status
              _selectedOption = ''; // Reset selected option
            });
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
          print('Error processing snapshot data: $e');
        }
      }
    }, onError: (error) {
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

      await _sessionRef.update({
        widget.role == 'parent' ? 'parentSubmittedAnswer' : 'childSubmittedAnswer': answer,
      });

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

        // Reset answers to null
        await _sessionRef.update({
          'parentSubmittedAnswer': null,
          'childSubmittedAnswer': null,
        });

        _moveToWinOrLoseScreen();
      } else {
        setState(() {
          _waitingForOtherPlayer = true;
        });
      }
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  void _moveToWinOrLoseScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WinOrLoseScreen(isWin: _isMatch)),
    );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearPercentIndicator(
                  lineHeight: 5.0,
                  percent: 1.0 - _remainingTime / 8,
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
