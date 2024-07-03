import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jokerly/pages/lesson.dart';
import 'package:jokerly/utility.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/models/flashcard_model.dart';
import 'package:jokerly/widgets/flashcard_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorLabel {
  red('Red', Color.fromARGB(255, 255, 82, 82)),
  orange('Orange', Color.fromARGB(255, 255, 120, 67)),
  yellow('Yellow', Color.fromARGB(255, 243, 199, 76)),
  lime('Lime', Color.fromARGB(255, 147, 204, 54)),
  green('Green', Color.fromARGB(255, 76, 175, 79)),
  teal('Teal', Color.fromARGB(255, 15, 179, 162)),
  blue('Blue', Color.fromARGB(255, 83, 109, 254)),
  purple('Purple', Color.fromARGB(255, 180, 83, 197)),
  pink('Pink', Color.fromARGB(255, 243, 94, 144)),
  ;

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

class DeckPage extends StatefulWidget {
  final FlashcardDeck deck;

  const DeckPage({super.key, required this.deck});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  bool _edit = false;
  bool _showNewFC = false;
  final TextEditingController _descController = TextEditingController();
  Color _backgroundColor = Colors.grey;
  Color _gradientColor = Colors.grey.shade400;

  // -----------------------
  //        Functions
  // -----------------------
  void _resetState(bool isEdit) {
    setState(() {
      _edit = isEdit;
      _descController.text = widget.deck.description;
      _backgroundColor = widget.deck.color;
      _gradientColor =
          Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
    });
  }

  void _updateBgColor(Color newBackgroundColor) {
    setState(() {
      _backgroundColor = newBackgroundColor;
      _gradientColor =
          Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
    });
  }

  void _addFlashcard(String question, String answer) {
    RegExp validStr = RegExp(r"\S{1,}");
    if (validStr.allMatches(question).isEmpty ||
        validStr.allMatches(answer).isEmpty) {
      return;
    }

    String newUid = encode("${DateTime.now()}");
    Flashcard newFlashcard = Flashcard(
      uid: newUid,
      question: question,
      answer: answer,
    );
    setState(() {
      widget.deck.flashcards.add(newFlashcard);
      _showNewFC = false;
    });

    _saveDeck();
  }

  void _deleteFlashcard(Flashcard flashcard) {
    setState(() => widget.deck.flashcards.remove(flashcard));
    _saveDeck();
  }

  void _closeEdit() {
    widget.deck.description = _descController.text;
    widget.deck.color = _backgroundColor;

    setState(() => _edit = false);

    _saveDeck();
  }

  Future<void> _saveDeck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.deck.uid, widget.deck.toString());
  }

  Future<bool> _removeDeck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];
    deckUids.remove(widget.deck.uid);
    await prefs.setStringList('deck_uids', deckUids);
    await prefs.remove(widget.deck.uid);

    return true;
  }

  // -----------------------
  //        Override
  // -----------------------
  @override
  void initState() {
    super.initState();
    _descController.text = widget.deck.description;
    _backgroundColor = widget.deck.color;
    _gradientColor =
        Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: deckAppBar(),
      body: Stack(
        children: [
          flashcardList(),
          editMenu(context),
          flashcardsCount(context),
          learnBTN(),
          newFlashcard(),
        ],
      ),
      floatingActionButton: newFlashcardBTN(),
    );
  }

  // -----------------------
  //        Sub-parts
  // -----------------------
  AppBar deckAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      foregroundColor: Colors.white,
      toolbarHeight: 50,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0.0, 0.5, 1.0],
            colors: [
              _gradientColor,
              _backgroundColor,
              _gradientColor,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70.0),
            child: Text(
              widget.deck.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: 60,
          height: 60,
          child: IconButton(
            icon: const Icon(Icons.settings),
            selectedIcon: const Icon(Icons.close),
            isSelected: _edit,
            onPressed: () => _resetState(!_edit),
            tooltip: _edit ? "Close" : "Edit",
          ),
        ),
      ],
    );
  }

  Widget flashcardList() {
    return Container(
      alignment: Alignment.topLeft,
      child: ListView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        children: [
          GridView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            itemCount: widget.deck.flashcards.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) => FlashcardWidget(
              key: ValueKey(widget.deck.flashcards[index].uid),
              flashcard: widget.deck.flashcards[index],
              saveChanges: _saveDeck,
              deleteFlashcard: _deleteFlashcard,
            ),
          ),
          const SizedBox(height: 72.0),
        ],
      ),
    );
  }

  Positioned editMenu(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 150,
      child: Visibility(
        visible: _edit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 5,
              ),
            ],
            gradient: LinearGradient(
              stops: const [0.0, 0.5, 1.0],
              colors: [
                _gradientColor,
                _backgroundColor,
                _gradientColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    DropdownMenu(
                      width: 120,
                      label: const Text(
                        'Color',
                        style: TextStyle(color: Colors.white54),
                      ),
                      textStyle: const TextStyle(color: Colors.white),
                      enableSearch: false,
                      trailingIcon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      selectedTrailingIcon:
                          const Icon(Icons.arrow_drop_up, color: Colors.white),
                      initialSelection: _backgroundColor,
                      inputDecorationTheme: const InputDecorationTheme(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onSelected: (Color? newValue) =>
                          _updateBgColor(newValue ?? _backgroundColor),
                      dropdownMenuEntries: ColorLabel.values
                          .map<DropdownMenuEntry<Color>>((ColorLabel color) {
                        return DropdownMenuEntry<Color>(
                            value: color.color,
                            label: color.label,
                            leadingIcon:
                                Icon(Icons.circle, color: color.color));
                      }).toList(),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TextField(
                        maxLength: 150,
                        style: const TextStyle(color: Colors.white),
                        controller: _descController,
                        decoration: const InputDecoration(
                          label: Text(
                            "Description",
                            style: TextStyle(color: Colors.white54),
                          ),
                          hintText:
                              "A description for the content of this deck",
                          hintStyle: TextStyle(color: Colors.white70),
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 60,
                    height: 50,
                    child: IconButton(
                      iconSize: 25.0,
                      onPressed: () =>
                          _removeDeck().then((value) => Navigator.pop(context)),
                      icon:
                          const Icon(Icons.delete_forever, color: Colors.white),
                      tooltip: "Delete deck",
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 50,
                    child: IconButton(
                      onPressed: () => _closeEdit(),
                      icon: const Icon(Icons.save, color: Colors.white),
                      tooltip: "Save changes",
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned newFlashcard() {
    TextEditingController qstController = TextEditingController();
    TextEditingController ansController = TextEditingController();

    return Positioned(
      bottom: 90.0,
      right: 20.0,
      width: min(400, (MediaQuery.sizeOf(context).width - 40.0)),
      child: Visibility(
        visible: _showNewFC,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12)
                .copyWith(bottomRight: const Radius.circular(0)),
            boxShadow: const [
              BoxShadow(
                offset: Offset(-3, 5),
                spreadRadius: 0,
                blurRadius: 10,
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                maxLength: 70,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: Colors.white70),
                  counterStyle: TextStyle(fontSize: 9.0, color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                controller: qstController,
              ),
              TextField(
                maxLength: 240,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  labelStyle: TextStyle(color: Colors.white70),
                  counterStyle: TextStyle(fontSize: 9.0, color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                controller: ansController,
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () =>
                    _addFlashcard(qstController.text, ansController.text),
                icon: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white70),
                    SizedBox(width: 5),
                    Text(
                      "Add flashcard",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned learnBTN() {
    return Positioned(
      left: 16,
      bottom: 16,
      width: 56,
      height: 56,
      child: Visibility(
        visible: widget.deck.flashcards.isNotEmpty,
        child: Container(
          decoration: BoxDecoration(
            color: widget.deck.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(196, 196, 196, 1),
                offset: Offset(8.0, 12.0),
                spreadRadius: -8.0,
                blurRadius: 5.0,
              ),
              BoxShadow(
                color: Color.fromRGBO(196, 196, 196, 1),
                offset: Offset(-8.0, 12.0),
                spreadRadius: -8.0,
                blurRadius: 5.0,
              ),
            ],
          ),
          child: IconButton(
            iconSize: 22.0,
            tooltip: "Start a lesson",
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => LessonPage(deck: widget.deck)),
            ),
            icon: const Icon(Icons.school_sharp, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Positioned flashcardsCount(BuildContext context) {
    String count =
        "${widget.deck.flashcards.length} card${widget.deck.flashcards.length > 1 ? 's' : ''}";

    return Positioned(
      left: 10,
      right: 10,
      bottom: 0,
      height: 88,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface.withAlpha(0),
              Theme.of(context).colorScheme.surface,
            ],
            stops: const [0.0, 0.2],
          ),
        ),
        child: Center(
          child: Text(count),
        ),
      ),
    );
  }

  FloatingActionButton newFlashcardBTN() {
    return FloatingActionButton(
      key: ValueKey("${widget.deck.uid}_addnew"),
      tooltip: _showNewFC ? "Close" : "Add a new flashcard",
      backgroundColor: _backgroundColor,
      foregroundColor: Colors.white,
      onPressed: () => setState(() => _showNewFC = !_showNewFC),
      child: Transform(
        transform: Matrix4.rotationZ((_showNewFC ? 45.0 : 0.0) * pi / 180),
        origin: const Offset(12, 12),
        child: const Icon(Icons.add),
      ),
    );
  }
}
