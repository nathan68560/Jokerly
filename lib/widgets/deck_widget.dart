import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/pages/deck.dart';

class FlashcardDeckWidget extends StatefulWidget {
  final FlashcardDeck deck;

  const FlashcardDeckWidget({super.key, required this.deck});

  @override
  State<FlashcardDeckWidget> createState() => _FlashcardDeckWidgetState();
}

class _FlashcardDeckWidgetState extends State<FlashcardDeckWidget> {
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
          CupertinoPageRoute(builder: (_) => DeckPage(deck: widget.deck)),
        ).then((_) => setState(() {}));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.8),
            radius: 2,
            stops: const [0.0, 1.0],
            colors: [
              widget.deck.color,
              Color.alphaBlend(widget.deck.color.withAlpha(200), Colors.white),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: const Offset(3, 5),
              spreadRadius: 0,
              blurRadius: 2,
              color: widget.deck.color.withAlpha(50),
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
                      widget.deck.title,
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
                      widget.deck.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${widget.deck.flashcards.length} flashcard${widget.deck.flashcards.length > 1 ? "s" : ""}",
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
