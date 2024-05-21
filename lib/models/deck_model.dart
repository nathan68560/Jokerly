import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardDeck {
  final String title;
  final Color color;
  final String description;
  final List<Flashcard> flashcards;

  FlashcardDeck({
    required this.title,
    required this.color,
    required this.description,
    required this.flashcards,
  });
}
