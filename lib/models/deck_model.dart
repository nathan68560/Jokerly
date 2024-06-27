import 'package:jokerly/utility.dart';
import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardDeck {
  final String uid;
  final String title;
  Color color;
  String description;
  List<Flashcard> flashcards;

  FlashcardDeck({
    required this.uid,
    required this.title,
    required this.color,
    required this.description,
    required this.flashcards,
  });

  @override
  String toString() {
    return "{uid: '$uid', title: '${encode(title)}', color: '${color.value}', description: '${encode(description)}', flashcards: [${flashcards.join(', ')}]}";
  }

  /// Create a FlashcardDeck object from a string representation
  factory FlashcardDeck.fromString(String flashcardDeckString) {
    final uidPattern = RegExp(r"uid: '([^']+)'");
    final titlePattern = RegExp(r"title: '([^']+)'");
    final colorPattern = RegExp(r"color: '([0-9]+)'");
    final descriptionPattern = RegExp(r"description: '([^']+)'");
    final flashcardsPattern = RegExp(r"flashcards: \[(.+)\]");

    final uidMatch = uidPattern.firstMatch(flashcardDeckString);
    final titleMatch = titlePattern.firstMatch(flashcardDeckString);
    final colorMatch = colorPattern.firstMatch(flashcardDeckString);
    final descriptionMatch = descriptionPattern.firstMatch(flashcardDeckString);
    final flashcardsMatch = flashcardsPattern.firstMatch(flashcardDeckString);

    if (uidMatch != null &&
        titleMatch != null &&
        colorMatch != null &&
        descriptionMatch != null) {
      List<Flashcard> flashcardsList = [];
      if (flashcardsMatch != null) {
        final flashcardsString = flashcardsMatch.group(1)!;
        flashcardsList =
            flashcardsString.split(RegExp(r'},\s*\{')).map((flashcardString) {
          if (!flashcardString.startsWith('{')) {
            flashcardString = '{$flashcardString';
          }
          if (!flashcardString.endsWith('}')) {
            flashcardString = '$flashcardString}';
          }
          return Flashcard.fromString(flashcardString);
        }).toList();
      }

      return FlashcardDeck(
        uid: uidMatch.group(1)!,
        title: decode(titleMatch.group(1)!),
        color: Color(int.parse(colorMatch.group(1)!)),
        description: decode(descriptionMatch.group(1)!),
        flashcards: flashcardsList,
      );
    } else {
      throw const FormatException('Invalid object format');
    }
  }
}
