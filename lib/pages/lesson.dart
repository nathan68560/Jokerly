import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';

class LessonPage extends StatefulWidget {
  final FlashcardDeck deck;

  const LessonPage({super.key, required this.deck});

  @override
  State<StatefulWidget> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Size _size;
  Color _backgroundColor = Colors.grey;

  //  4 lesson variants depending on card's SRS score:
  //
  //  1. Select answer from multiple flashcard  (Easy)
  //  2. Assemble answer from multiple words    (Medium)
  //  3. Complete missing part of answer        (Medium+)
  //  4. Write the answer                       (Hard)

  // -----------------------
  //        Override
  // -----------------------
  @override
  void initState() {
    super.initState();
    _backgroundColor = widget.deck.color;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          fakeAppBar(),
        ],
      ),
    );
  }

  // -----------------------
  //        Sub-parts
  // -----------------------
  Positioned fakeAppBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: _size.height / 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.elliptical(50, 40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deck.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
