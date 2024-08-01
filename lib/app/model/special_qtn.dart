import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addSpecialQuestion() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final specialQuestionData = {
    'kidQuestion': 'What is your favorite lunch meal?',
    'parentQuestion': 'What is your kid\'s favorite lunch meal?',
    'options': [
      'Pizza', 'Burger', 'Pasta', 'Salad', 'Sandwich', 'Sushi', 'Tacos', 'Steak', 'Soup', 'Fried Chicken'
    ],
    'parentSubmittedAnswer': null,
    'childSubmittedAnswer': null,
    'showPopup': false,
    'matched': false,
  };

  try {
    await _firestore.collection('specialSession').doc('specialQuestion').set(specialQuestionData);
    print('Special question added successfully.');
  } catch (e) {
    print('Error adding special question: $e');
  }
}
