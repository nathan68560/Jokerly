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

class _LessonPageState extends State<LessonPage> with TickerProviderStateMixin {
  late Size _size;
  late int _progress;
  late int _lessonLength;
  late Animation _inAnimTrans;
  late Animation _inAnimRot;
  late Animation _inAnimSize;
  late Animation _outAnimTrans;
  late Animation _outAnimRot;
  late Animation _outAnimSize;
  late AnimationController _animController;
  final Map<int, int> _targetLevels = {0: 12, 1: 6, 2: 2};
  bool _isInAnim = true;
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
  void initFlashcards(List<Flashcard> deckFlashcards) {
    _progress = 0;
    _lessonLength = _targetLevels.values.reduce((a, b) => a + b);
    // Sort flashcards from least to most seen and randomize those equally seen
    deckFlashcards
      ..shuffle()
      ..sort((a, b) => a.seenCount.compareTo(b.seenCount));

    if (deckFlashcards.length <= _lessonLength) {
      // If less than flashcardCount cards, select all
      _lessonFlashcards = deckFlashcards;
      _lessonLength = deckFlashcards.length;
    } else {
      // Else fill from the top
      int currLvl = _targetLevels.keys.last;
      while (_lessonFlashcards.length < _lessonLength) {
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
            int fillAmount = _lessonLength - _lessonFlashcards.length;
            _lessonFlashcards.addAll(deckFlashcards.take(fillAmount));
            break;
          }
        }
      }
    }
  }

  /// Initialize the in/out animations for the flashcard
  void initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: Durations.medium3,
    );
    CurvedAnimation curvedInAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInSine,
    );
    CurvedAnimation curvedOutAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutSine,
    );

    _inAnimTrans = Tween(
      begin: 300.0,
      end: 0.0,
    ).animate(curvedOutAnim);
    _inAnimRot = Tween(
      begin: 0.8,
      end: 0.0,
    ).animate(curvedOutAnim);
    _inAnimSize = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(curvedOutAnim);

    _outAnimTrans = Tween(
      begin: 0.0,
      end: -300.0,
    ).animate(curvedInAnim);
    _outAnimRot = Tween(
      begin: 0.0,
      end: -0.8,
    ).animate(curvedInAnim);
    _outAnimSize = Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(curvedInAnim);
  }

  /// Animate the changes to the next flashcard
  void nextFlashcard() {
    setState(() => _isInAnim = false);
    _animController
      ..reset()
      ..forward().then((_) {
        if (_progress < _lessonLength - 1) {
          // While it's not the last flashcard, increment progress to the next
          setState(() {
            _progress++;
            _isInAnim = true;
          });
          _animController
            ..reset()
            ..forward();
        } else {
          // Otherwise quit the lesson
          _animController.reset();
          Navigator.pop(context);
        }
      });
  }

  // -----------------------
  //        Override
  // -----------------------
  @override
  void initState() {
    super.initState();
    _backgroundColor = widget.deck.color;
    initFlashcards(widget.deck.flashcards);
    initAnimations();
    _animController.forward();
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
            bottom: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                flashcard(width, height),
                progressIndicator(width),
                actionBTN(width, context),
              ],
            ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget flashcard(double width, double height) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..translate(_isInAnim ? _inAnimTrans.value : _outAnimTrans.value)
          ..rotateZ(_isInAnim ? _inAnimRot.value : _outAnimRot.value)
          ..scale(_isInAnim ? _inAnimSize.value : _outAnimSize.value),
        child: SizedBox(
          width: width,
          height: height,
          child: FlashcardWidget(
            key: ValueKey(_lessonFlashcards[_progress].uid),
            flashcard: _lessonFlashcards[_progress],
          ),
        ),
      ),
    );
  }

  Widget progressIndicator(double width) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress / _lessonLength,
          minHeight: 30,
          color: widget.deck.color,
          borderRadius: BorderRadius.circular(15.0),
          semanticsLabel: "Completion progress for this lesson",
        ),
        const SizedBox(height: 5.0),
        Text(
          "$_progress/$_lessonLength",
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 9.0,
          ),
        ),
      ],
    );
  }

  Widget actionBTN(double width, BuildContext context) {
    return InkWell(
      splashColor: Colors.white24,
      onTap: _isInAnim ? nextFlashcard : () {},
      child: Container(
        height: 80.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isInAnim ? widget.deck.color : Colors.grey,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          _progress == _lessonLength - 1 ? "Done" : "Next",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
