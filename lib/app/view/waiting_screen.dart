import 'package:back_to_school/app/controller/waiting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class WaitingScreen extends StatelessWidget {
  final WaitingController controller = Get.put(WaitingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFA629),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFA629),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFA629), // Set fixed orange background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Play:',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Each player answers the questions.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    '2. Try to match the answers with your partner.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    '3. The game ends when both players have answered.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    '4. The score is calculated based on matching answers.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Waiting for the other player to be ready...',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Obx(() => ElevatedButton(
                      onPressed: controller.isReady.value
                          ? null
                          : () {
                              controller.setReady();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        controller.isReady.value ? 'Ready!' : 'I\'m Ready',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
