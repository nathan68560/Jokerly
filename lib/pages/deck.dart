import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/widgets/flashcard_widget.dart';

class DeckPage extends StatefulWidget {
  final FlashcardDeck deck;

  const DeckPage({super.key, required this.deck});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: deckAppBar(context),
      body: Container(
        alignment: Alignment.topLeft,
        child: ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: widget.deck.flashcards.length,
          scrollDirection: Axis.vertical,
          separatorBuilder: (context, index) => const SizedBox(height: 20.0),
          itemBuilder: (context, index) =>
              FlashcardWidget(flashcard: widget.deck.flashcards[index]),
        ),
      ),
    );
  }

  AppBar deckAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: widget.deck.color,
      foregroundColor: Colors.white,
      toolbarHeight: 50,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 10,
            stops: const [0.0, 1.0],
            colors: [
              widget.deck.color,
              Color.alphaBlend(widget.deck.color.withAlpha(180), Colors.white),
            ],
          ),
        ),
        child: Center(
          child: Text(
            widget.deck.title,
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: 60,
          height: 60,
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => print("Edit"),
          ),
        ),
      ],
    );
  }
}
