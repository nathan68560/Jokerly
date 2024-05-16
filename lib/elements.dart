import 'package:flutter/material.dart';

class Flashcard {
  final Widget question;
  final Widget answer;

  Flashcard({
    required this.question,
    required this.answer,
  });
}

class FlashcardDeck {
  final String title;
  final String description;
  final List<Flashcard> flashcards;

  FlashcardDeck({
    required this.title,
    required this.description,
    required this.flashcards,
  });
}

class FlashcardDeckWidget extends StatelessWidget {
  final FlashcardDeck deck;

  const FlashcardDeckWidget({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the deck title
        Text(
          deck.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Display the deck description
        Text(deck.description),
        // Display the list of flashcards
        Column(
          children: deck.flashcards.map((flashcard) {
            return FlashcardWidget(flashcard: flashcard);
          }).toList(),
        ),
        // Add button to add new flashcards, or other deck options
      ],
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({super.key, required this.flashcard});

  @override
  State<FlashcardWidget> createState() => _FlashcardState();
}

class _FlashcardState extends State<FlashcardWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
