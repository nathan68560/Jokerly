import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/models/flashcard_model.dart';
import 'package:jokerly/widgets/flashcard_widget.dart';

class LessonPage extends StatefulWidget {
  final FlashcardDeck deck;

  const LessonPage({super.key, required this.deck});

  @override
  State<StatefulWidget> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Size _size;
  final Map<int, int> _targetLevels = {0: 12, 1: 6, 2: 2};
  Color _backgroundColor = Colors.grey;
  List<Flashcard> _lessonFlashcards = [];

  //  TODO:
  //  0: Multiple choice    (Easy)
  //  1: Fill in the blank  (Medium)
  //  2: Write the answer   (Hard)

  // -----------------------
  //        Functions
  // -----------------------
  /// Construct a list of the flashcards that will be seen in this lesson.
  /// Preferrably following the repartition and count defined by _targetLevels.
  void selectFlashcards(List<Flashcard> deckFlashcards) {
    int flashcardCount = _targetLevels.values.reduce((a, b) => a + b);

    if (deckFlashcards.length <= flashcardCount) {
      // If less than flashcardCount cards, select all
      _lessonFlashcards = deckFlashcards;
    } else {
      // Else fill from the top
      int currLvl = _targetLevels.keys.last;
      while (_lessonFlashcards.length < flashcardCount) {
        int currLvlCount =
            _lessonFlashcards.where((f) => f.srsLevel == currLvl).length;
        int remaining = _targetLevels[currLvl]! - currLvlCount;

        if (remaining > 0 && currLvlCount > 0) {
          // Add Flashcards from current level
          _lessonFlashcards.addAll(deckFlashcards
              .where((f) => f.srsLevel == currLvl)
              .take(remaining));
          deckFlashcards
              .removeWhere((f) => f.srsLevel == currLvl && remaining-- > 0);
        } else {
          // Move to lower level and compensate
          currLvl--;
          if (currLvl < 0) {
            // Not enough flashcards, fill with remaining cards
            int fillAmount = flashcardCount - _lessonFlashcards.length;
            _lessonFlashcards.addAll(deckFlashcards.take(fillAmount));
            break;
          }
        }
      }
    }
  }

  // -----------------------
  //        Override
  // -----------------------
  @override
  void initState() {
    super.initState();
    _backgroundColor = widget.deck.color;
    selectFlashcards(widget.deck.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    double width = min(400.0, _size.width - 80.0);
    double height = min(width * 1.5, _size.height / 2);

    return Scaffold(
      body: Stack(
        children: [
          fakeAppBar(),
          Positioned(
            top: _size.height / 7,
            left: (_size.width - width) / 2,
            width: width,
            height: height,
            child: FlashcardWidget(flashcard: _lessonFlashcards.first),
          ),
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
      height: _size.height / 4,
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
