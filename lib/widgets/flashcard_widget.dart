import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final Function saveChanges;
  final Function deleteFlashcard;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.saveChanges,
    required this.deleteFlashcard,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardState();
}

class _FlashcardState extends State<FlashcardWidget>
    with TickerProviderStateMixin {
  final TextEditingController _qstController = TextEditingController();
  final TextEditingController _ansController = TextEditingController();
  late AnimationController _controller;
  late Animation _animation;
  AnimationStatus _status = AnimationStatus.dismissed;
  bool _edit = false;

  // -----------------------
  //        Functions
  // -----------------------
  void _saveChanges() {
    RegExp validStr = RegExp(r"\S{1,}");
    if (validStr.allMatches(_qstController.text).isEmpty ||
        validStr.allMatches(_ansController.text).isEmpty) return;

    widget.flashcard.question = _qstController.text;
    widget.flashcard.answer = _ansController.text;
    setState(() => _edit = false);
    widget.saveChanges();
  }

  void _deleteFlashcard() {
    setState(() => _edit = false);
    widget.deleteFlashcard(widget.flashcard);
  }

  // -----------------------
  //        Override
  // -----------------------
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _status = status;
      });

    _qstController.text = widget.flashcard.question;
    _ansController.text = widget.flashcard.answer;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform(
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
            child: _controller.value > 0.5 ? backSide() : frontSide(),
          ),
        ),
        editActions(),
      ],
    );
  }

  // -----------------------
  //        Sub-parts
  // -----------------------
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
        child: TextField(
          maxLines: 4,
          minLines: 1,
          enabled: _edit,
          controller: _qstController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Color(0xff2a2a2a),
          ),
          decoration: const InputDecoration(
            counterText: '',
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
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
          child: TextField(
            maxLines: 4,
            minLines: 1,
            enabled: _edit,
            controller: _ansController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              counterText: '',
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned editActions() {
    return Positioned(
      top: 5,
      left: 5,
      right: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          !_edit
              ? IconButton(
                  tooltip: "Edit",
                  icon: Icon(
                    Icons.edit,
                    color: _controller.value > 0.5
                        ? Colors.white
                        : const Color(0xff2a2a2a),
                  ),
                  onPressed: () => setState(() => _edit = true),
                )
              : IconButton(
                  tooltip: "Save",
                  icon: const Icon(Icons.save, color: Colors.green),
                  onPressed: () => _saveChanges(),
                ),
          Visibility(
            visible: _edit,
            child: IconButton(
              tooltip: "Delete",
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFlashcard(),
            ),
          ),
        ],
      ),
    );
  }
}
