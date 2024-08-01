
import 'package:back_to_school/app/view/role_selection_screen.dart';
import 'package:flutter/material.dart';


class WinOrLoseScreen extends StatelessWidget {
  final bool isWin;

  const WinOrLoseScreen({super.key, required this.isWin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWin ? 'You Win!' : 'You Lose!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RoleSelectionScreen()),
                  );
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
