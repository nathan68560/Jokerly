import 'package:jokerly/utility.dart';

class Flashcard {
  final String question;
  final String answer;

  Flashcard({
    required this.question,
    required this.answer,
  });

  @override
  String toString() {
    return "{question: '${encode(question)}', answer: '${encode(answer)}'}";
  }

  // Create a Flashcard object from a string representation
  factory Flashcard.fromString(String flashcardString) {
    final questionPattern = RegExp(r"question: '([^']+)'");
    final answerPattern = RegExp(r"answer: '([^']+)'");

    final questionMatch = questionPattern.firstMatch(flashcardString);
    final answerMatch = answerPattern.firstMatch(flashcardString);

    if (questionMatch != null && answerMatch != null) {
      return Flashcard(
        question: decode(questionMatch.group(1)!),
        answer: decode(answerMatch.group(1)!),
      );
    } else {
      throw const FormatException('Invalid flashcard format');
    }
  }
}
