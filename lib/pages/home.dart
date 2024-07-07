import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/pages/deck.dart';
import 'package:jokerly/utility.dart';
import 'package:jokerly/widgets/deck_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showNewDeck = false;
  List<FlashcardDeck> _decks = [];

  // -----------------------
  //        Functions
  // -----------------------
  Future<void> _getDecks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _decks = [];
    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];

    for (String uid in deckUids) {
      try {
        _decks.add(FlashcardDeck.fromString(prefs.getString(uid)!));
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _addDeck(String title, String desc, Color color) async {
    RegExp validStr = RegExp(r"\S{2,}");
    if (validStr.allMatches(title).isEmpty ||
        validStr.allMatches(desc).isEmpty) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Add reference to this deck through a unique ID
    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];
    String newUid;
    do {
      newUid = encode("${DateTime.now()}+$title");
    } while (deckUids.contains(newUid));
    deckUids.add(newUid);
    await prefs.setStringList('deck_uids', deckUids);

    // Save this deck as his unique ID value
    FlashcardDeck newDeck = FlashcardDeck(
      uid: newUid,
      title: title,
      color: color,
      description: desc,
      flashcards: [],
    );
    await prefs.setString(newUid, newDeck.toString());

    setState(() {
      _showNewDeck = false;
    });
  }

  // -----------------------
  //        Override
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: Stack(
        children: [
          myDecks(),
          newDeck(),
        ],
      ),
      floatingActionButton: newDeckBTN(context),
    );
  }

  // -----------------------
  //        Sub-parts
  // -----------------------
  AppBar homeAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.elliptical(150, 25),
          ),
        ),
        child: const Center(
          child: Text(
            "My Decks",
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w500,
              color: Color(0xff2a2a2a),
            ),
          ),
        ),
      ),
    );
  }

  Widget myDecks() {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(20.0).copyWith(top: 0),
      child: FutureBuilder(
        future: _getDecks(),
        builder: (context, snapshot) => GridView.builder(
          clipBehavior: Clip.none,
          itemCount: _decks.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) => FlashcardDeckWidget(
            key: ValueKey(_decks[index].uid),
            deck: _decks[index],
            refresh: () => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget newDeck() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    Color bgColor = ColorLabel.blue.color;

    return Visibility(
      visible: _showNewDeck,
      child: Positioned(
        bottom: 90.0,
        right: 20.0,
        width: min(400, (MediaQuery.sizeOf(context).width - 40.0)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)
                .copyWith(bottomRight: const Radius.circular(0)),
            boxShadow: const [
              BoxShadow(
                offset: Offset(-3, 5),
                spreadRadius: -3,
                blurRadius: 10,
                color: Colors.black12,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DropdownMenu(
                    label: const Text('Color'),
                    width: 130,
                    enableSearch: false,
                    initialSelection: ColorLabel.blue.color,
                    inputDecorationTheme: const InputDecorationTheme(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    dropdownMenuEntries: ColorLabel.values
                        .map<DropdownMenuEntry<Color>>((ColorLabel color) {
                      return DropdownMenuEntry<Color>(
                        value: color.color,
                        label: color.label,
                        leadingIcon: Icon(Icons.circle, color: color.color),
                      );
                    }).toList(),
                    onSelected: (newValue) => bgColor = newValue!,
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: TextField(
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Title',
                      ),
                      controller: titleController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                maxLength: 150,
                decoration: const InputDecoration(
                  counterStyle: TextStyle(fontSize: 9.0),
                  labelText: 'Description',
                ),
                controller: descController,
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => _addDeck(
                    titleController.text, descController.text, bgColor),
                icon: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 5),
                    Text("Add deck"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton newDeckBTN(BuildContext context) {
    return FloatingActionButton(
      tooltip: _showNewDeck ? "Close" : "Add a new deck",
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      foregroundColor: Theme.of(context).colorScheme.surface,
      onPressed: () => setState(() => _showNewDeck = !_showNewDeck),
      child: Transform(
        transform: Matrix4.rotationZ((_showNewDeck ? 45.0 : 0.0) * pi / 180),
        origin: const Offset(12, 12),
        child: const Icon(Icons.add),
      ),
    );
  }
}
