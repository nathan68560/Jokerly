import 'package:jokerly/utility.dart';

class Flashcard {
  final String uid;

  String question;
  String answer;

  int srsLevel;
  int seenCount;
  int successCount;

  Flashcard({
    required this.uid,
    required this.question,
    required this.answer,
    this.srsLevel = 0,
    this.seenCount = 0,
    this.successCount = 0,
  });

  @override
  String toString() {
    return "{uid: '$uid', question: '${encode(question)}', answer: '${encode(answer)}', srs: '$srsLevel', seen: '$seenCount', success: '$successCount'}";
  }

  // Create a Flashcard object from a string representation
  factory Flashcard.fromString(String flashcardString) {
    final uidPattern = RegExp(r"uid: '([^']+)'");
    final questionPattern = RegExp(r"question: '([^']+)'");
    final answerPattern = RegExp(r"answer: '([^']+)'");
    final srsPattern = RegExp(r"srs: '(\d+)'");
    final seenPattern = RegExp(r"seen: '(\d+)'");
    final successPattern = RegExp(r"success: '(\d+)'");

    final uidMatch = uidPattern.firstMatch(flashcardString);
    final questionMatch = questionPattern.firstMatch(flashcardString);
    final answerMatch = answerPattern.firstMatch(flashcardString);
    final srsMatch = srsPattern.firstMatch(flashcardString);
    final seenMatch = seenPattern.firstMatch(flashcardString);
    final successMatch = successPattern.firstMatch(flashcardString);

    if (uidMatch != null && questionMatch != null && answerMatch != null) {
      return Flashcard(
        uid: uidMatch.group(1)!,
        question: decode(questionMatch.group(1)!),
        answer: decode(answerMatch.group(1)!),
        srsLevel: int.parse(srsMatch?.group(1) ?? '0'),
        seenCount: int.parse(seenMatch?.group(1) ?? '0'),
        successCount: int.parse(successMatch?.group(1) ?? '0'),
      );
    } else {
      throw const FormatException('Invalid flashcard format');
    }
  }
}
