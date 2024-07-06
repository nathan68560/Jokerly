import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jokerly/models/flashcard_model.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final Function? saveChanges;
  final Function? deleteFlashcard;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    this.saveChanges,
    this.deleteFlashcard,
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
  bool _editable = true;

  // -----------------------
  //        Functions
  // -----------------------
  void _saveChanges() {
    if (!_editable) return;

    RegExp validStr = RegExp(r"\S{1,}");
    if (validStr.allMatches(_qstController.text).isEmpty ||
        validStr.allMatches(_ansController.text).isEmpty) return;

    widget.flashcard.question = _qstController.text;
    widget.flashcard.answer = _ansController.text;
    setState(() => _edit = false);
    widget.saveChanges!();
  }

  void _deleteFlashcard() {
    if (!_editable) return;

    setState(() => _edit = false);
    widget.deleteFlashcard!(widget.flashcard);
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
    _editable = widget.deleteFlashcard != null && widget.saveChanges != null;
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
                _status == AnimationStatus.dismissed
                    ? _controller.forward()
                    : _controller.reverse();
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
  _FlashcardSide frontSide() {
    return _FlashcardSide(
      key: ObjectKey("${widget.flashcard.uid}_front"),
      rad: 0,
      color: Colors.white,
      textColor: const Color(0xff2a2a2a),
      textController: _qstController,
      maxTextLength: 70,
      edit: _edit,
    );
  }

  _FlashcardSide backSide() {
    return _FlashcardSide(
      key: ObjectKey("${widget.flashcard.uid}_back"),
      rad: pi,
      color: const Color(0xff2a2a2a),
      textColor: Colors.white,
      textController: _ansController,
      maxTextLength: 240,
      edit: _edit,
    );
  }

  Positioned editActions() {
    double recalRatio = 100 *
        widget.flashcard.successCount /
        max(1, widget.flashcard.seenCount);

    return Positioned(
      top: 5,
      left: 5,
      right: 5,
      bottom: 5,
      child: Visibility(
        visible: _editable,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                !_edit
                    ? IconButton(
                        tooltip: "Edit",
                        icon: Icon(
                          Icons.edit,
                          color: Colors.grey.withOpacity(0.35),
                        ),
                        onPressed: () => setState(() => _edit = true),
                      )
                    : IconButton(
                        tooltip: "Save",
                        icon: const Icon(Icons.save, color: Colors.green),
                        onPressed: _saveChanges,
                      ),
                Visibility(
                  visible: _edit,
                  child: IconButton(
                    tooltip: "Delete",
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteFlashcard,
                  ),
                ),
              ],
            ),
            IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 5.0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_sharp,
                          size: 16.0,
                          color: Colors.grey.withOpacity(0.35),
                          semanticLabel: "Seen count icon",
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.flashcard.seenCount.toString(),
                          semanticsLabel:
                              "Seen count: ${widget.flashcard.seenCount}",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 15.0,
                          color: Colors.grey.withOpacity(0.35),
                          semanticLabel: "Recall ratio icon",
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "$recalRatio%",
                          semanticsLabel: "Successful recall: $recalRatio%",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardSide extends StatelessWidget {
  const _FlashcardSide({
    super.key,
    required this.rad,
    required this.color,
    required this.textColor,
    required this.textController,
    required this.maxTextLength,
    required this.edit,
  });

  final double rad;
  final Color color;
  final Color textColor;
  final TextEditingController textController;
  final int maxTextLength;
  final bool edit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 35.0),
      decoration: BoxDecoration(
        color: color,
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
          transform: Matrix4.identity()..rotateY(rad),
          child: IgnorePointer(
            ignoring: !edit,
            child: TextField(
              maxLines: null,
              minLines: 1,
              maxLength: maxTextLength,
              readOnly: !edit,
              controller: textController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                counterText: edit ? null : '',
                counterStyle: TextStyle(
                  fontSize: 9.0,
                  color: Colors.grey.withOpacity(.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: edit ? Colors.grey : Colors.transparent,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: edit
                        ? Colors.grey.withOpacity(.35)
                        : Colors.transparent,
                  ),
                ),
                disabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
