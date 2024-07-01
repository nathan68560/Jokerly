import 'package:jokerly/utility.dart';

class Flashcard {
  final String uid;
  String question;
  String answer;

  Flashcard({
    required this.uid,
    required this.question,
    required this.answer,
  });

  @override
  String toString() {
    return "{uid: '$uid', question: '${encode(question)}', answer: '${encode(answer)}'}";
  }

  // Create a Flashcard object from a string representation
  factory Flashcard.fromString(String flashcardString) {
    final uidPattern = RegExp(r"uid: '([^']+)'");
    final questionPattern = RegExp(r"question: '([^']+)'");
    final answerPattern = RegExp(r"answer: '([^']+)'");

    final uidMatch = uidPattern.firstMatch(flashcardString);
    final questionMatch = questionPattern.firstMatch(flashcardString);
    final answerMatch = answerPattern.firstMatch(flashcardString);

    if (uidMatch != null && questionMatch != null && answerMatch != null) {
      return Flashcard(
        uid: uidMatch.group(1)!,
        question: decode(questionMatch.group(1)!),
        answer: decode(answerMatch.group(1)!),
      );
    } else {
      throw const FormatException('Invalid flashcard format');
    }
  }
}
