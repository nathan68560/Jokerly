import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/pages/deck.dart';
import 'package:jokerly/widgets/deck_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int folderIndex = 0;
  List<FlashcardDeck> decks = [];

  Future<void> _getDecks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    decks = [];
    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];

    for (String uid in deckUids) {
      try {
        decks.add(FlashcardDeck.fromString(prefs.getString(uid)!));
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _addDeck(String title, String desc, Color color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Add reference to this deck through a unique ID
    List<String> deckUids = prefs.getStringList('deck_uids') ?? [];
    String newUid;
    do {
      newUid = base64.encode(utf8.encode("${DateTime.now()}+$title"));
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
      folderIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(20.0).copyWith(top: 0),
        child: switch (folderIndex) {
          1 => newDeck(),
          //2 => myProfile(),
          _ => myDecks(),
        },
      ),
      bottomNavigationBar: bottomNavBar(context),
    );
  }

  FutureBuilder<void> myDecks() {
    return FutureBuilder(
        future: _getDecks(),
        builder: (context, snapshot) {
          return GridView.builder(
            clipBehavior: Clip.none,
            itemCount: decks.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 600,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) =>
                FlashcardDeckWidget(deck: decks[index]),
          );
        });
  }

  Widget newDeck() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    Color bgColor = ColorLabel.blue.color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
          controller: titleController,
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Description',
          ),
          controller: descController,
        ),
        const SizedBox(height: 20),
        DropdownMenu(
          label: const Text('Color'),
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
        const SizedBox(height: 40),
        IconButton(
          onPressed: () =>
              _addDeck(titleController.text, descController.text, bgColor),
          icon: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 5),
              Text("Add new deck"),
            ],
          ),
        ),
      ],
    );
  }

  AppBar homeAppBar(BuildContext context) {
    List<String> appBarTitles = [
      "My Decks",
      "New Deck",
      "My Profile",
    ];

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
        child: Center(
          child: Text(
            appBarTitles[folderIndex],
            style: const TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w500,
              color: Color(0xff2a2a2a),
            ),
          ),
        ),
      ),
    );
  }

  Container bottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          iconSize: 30.0,
          selectedFontSize: 0.0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: const Color(0xff2a2a2a),
          currentIndex: folderIndex,
          onTap: (value) => setState(() {
            folderIndex = value;
          }),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_special_outlined),
              label: "My Decks",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: "Add deck",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
