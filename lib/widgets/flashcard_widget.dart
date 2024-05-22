import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({super.key, required this.flashcard});

  @override
  State<FlashcardWidget> createState() => _FlashcardState();
}

class _FlashcardState extends State<FlashcardWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _status = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(pi * _animation.value),
      alignment: FractionalOffset.center,
      child: InkWell(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              if (_status == AnimationStatus.dismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            });
          },
          child: _controller.value > 0.5 ? backSide() : frontSide()),
    );
  }

  Container frontSide() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            offset: Offset(1, 3),
            spreadRadius: 1,
            blurRadius: 1,
            color: Color.fromARGB(50, 158, 158, 158),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.flashcard.question,
          style: const TextStyle(
            color: Color(0xff2a2a2a),
          ),
        ),
      ),
    );
  }

  Container backSide() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: const Color(0xff2a2a2a),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            offset: Offset(1, 3),
            spreadRadius: 1,
            blurRadius: 1,
            color: Color.fromARGB(50, 158, 158, 158),
          ),
        ],
      ),
      child: Center(
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()..rotateY(pi),
          child: Text(
            widget.flashcard.answer,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
