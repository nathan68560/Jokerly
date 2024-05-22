import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/pages/deck.dart';

class FlashcardDeckWidget extends StatelessWidget {
  final FlashcardDeck deck;

  const FlashcardDeckWidget({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTapUp: (details) {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => DeckPage(deck: deck)),
        );
      },
      child: Container(
        height: 140.0,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.8),
            radius: 2,
            stops: const [0.0, 1.0],
            colors: [
              deck.color,
              Color.alphaBlend(deck.color.withAlpha(200), Colors.white),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: const Offset(3, 5),
              spreadRadius: 0,
              blurRadius: 2,
              color: deck.color.withAlpha(50),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      deck.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${deck.flashcards.length} flashcard${deck.flashcards.length > 1 ? "s" : ""}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white60,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
