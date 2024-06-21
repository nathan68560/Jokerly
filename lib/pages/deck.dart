import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
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
  final TextEditingController _descController = TextEditingController();
  Color _backgroundColor = Colors.grey;
  Color _gradientColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.deck.description;
    _backgroundColor = widget.deck.color;
    _gradientColor =
        Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
  }

  void resetState(bool isEdit) {
    setState(() {
      _edit = isEdit;
      _descController.text = widget.deck.description;
      _backgroundColor = widget.deck.color;
      _gradientColor =
          Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
    });
  }

  void updateBackgroundColor(Color newBackgroundColor) {
    setState(() {
      _backgroundColor = newBackgroundColor;
      _gradientColor =
          Color.alphaBlend(_backgroundColor.withAlpha(200), Colors.white);
    });
  }

  Future<void> saveFlashcardDeck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    widget.deck.description = _descController.text;
    widget.deck.color = _backgroundColor;

    await prefs.setString(widget.deck.uid, widget.deck.toString());

    setState(() => _edit = false);
  }

  Future<bool> removeFlashcardDeck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];
    deckUids.remove(widget.deck.uid);
    await prefs.setStringList('deck_uids', deckUids);
    await prefs.remove(widget.deck.uid);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: deckAppBar(context),
      body: Container(
        alignment: Alignment.topLeft,
        child: ListView(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          children: [
            _edit ? editMenu(context) : const SizedBox(),
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
              itemBuilder: (context, index) =>
                  FlashcardWidget(flashcard: widget.deck.flashcards[index]),
            ),
          ],
        ),
      ),
    );
  }

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
            onPressed: () => resetState(!_edit),
            tooltip: _edit ? "Close" : "Edit",
          ),
        ),
      ],
    );
  }

  Container editMenu(BuildContext context) {
    return Container(
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
                      updateBackgroundColor(newValue ?? _backgroundColor),
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
                  onPressed: () => removeFlashcardDeck()
                      .then((value) => Navigator.pop(context)),
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  tooltip: "Delete deck",
                ),
              ),
              SizedBox(
                width: 60,
                height: 50,
                child: IconButton(
                  onPressed: () => saveFlashcardDeck(),
                  icon: const Icon(Icons.save, color: Colors.white),
                  tooltip: "Save changes",
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
