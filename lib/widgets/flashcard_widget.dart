import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({super.key, required this.flashcard});

  @override
  State<FlashcardWidget> createState() => _FlashcardState();
}

class _FlashcardState extends State<FlashcardWidget> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _showAnswer = !_showAnswer;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: _showAnswer ? const Color(0xff2a2a2a) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(1, 3),
              spreadRadius: 1,
              blurRadius: 1,
              color: Color.fromARGB(50, 158, 158, 158),
            ),
          ],
        ),
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              _showAnswer ? widget.flashcard.answer : widget.flashcard.question,
              style: TextStyle(
                color: _showAnswer ? Colors.white : const Color(0xff2a2a2a),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
