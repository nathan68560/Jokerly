import 'dart:math';
import 'package:flutter/material.dart';
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
      appBar: deckAppBar(context),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: ListView(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              children: [
                editMenu(context),
                flashcardList(context),
              ],
            ),
          ),
          newFlashcard(),
        ],
      ),
      floatingActionButton: newFlashcardBTN(),
    );
  }

  // -----------------------
  //        Sub-parts
  // -----------------------
  AppBar deckAppBar(BuildContext context) {
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
          child: Text(
            widget.deck.title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
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

  Widget editMenu(BuildContext context) {
    return Visibility(
      visible: _edit,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
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
                    trailingIcon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                          leadingIcon: Icon(Icons.circle, color: color.color));
                    }).toList(),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _descController,
                      decoration: const InputDecoration(
                        label: Text(
                          "Description",
                          style: TextStyle(color: Colors.white54),
                        ),
                        hintText: "A description for the content of this deck",
                        hintStyle: TextStyle(color: Colors.white70),
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
                    onPressed: () =>
                        _removeDeck().then((value) => Navigator.pop(context)),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
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
    );
  }

  GridView flashcardList(BuildContext context) {
    return GridView.builder(
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
    );
  }

  Widget newFlashcard() {
    TextEditingController qstController = TextEditingController();
    TextEditingController ansController = TextEditingController();

    return Visibility(
      visible: _showNewFC,
      child: Positioned(
        bottom: 90.0,
        right: 20.0,
        width: min(400, (MediaQuery.sizeOf(context).width - 40.0)),
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
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Question',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                controller: qstController,
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Answer',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                controller: ansController,
              ),
              const SizedBox(height: 40),
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

  FloatingActionButton newFlashcardBTN() {
    return FloatingActionButton(
      tooltip: _showNewFC ? "Close" : "Add new flashcard",
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
