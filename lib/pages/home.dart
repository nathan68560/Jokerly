import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/models/flashcard_model.dart';
import 'package:jokerly/widgets/deck_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FlashcardDeck> decks = [];

  void _getDecks() {
    decks.add(
      FlashcardDeck(
        title: "French",
        color: Colors.indigoAccent,
        description: "French words and expressions",
        flashcards: [
          Flashcard(question: "SuperGoldMagikarp", answer: "Af#r4|5@61"),
          Flashcard(
              question: "Embedding",
              answer: "Multi-dimensional representation of a token"),
          Flashcard(
              question: "Embedding",
              answer: "Multi-dimensional representation of a token"),
          Flashcard(
              question: "Embedding",
              answer: "Multi-dimensional representation of a token"),
        ],
      ),
    );

    decks.add(
      FlashcardDeck(
        title: "German",
        color: Colors.deepOrange.shade400,
        description: "German words and expressions",
        flashcards: [],
      ),
    );

    decks.add(
      FlashcardDeck(
        title: "Japanese",
        color: Colors.grey,
        description: "Japanese words and expressions",
        flashcards: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getDecks();
    return Scaffold(
      appBar: homeAppBar(context),
      body: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(20.0).copyWith(top: 0),
        child: GridView.builder(
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
        ),
      ),
      bottomNavigationBar: bottomNavBar(context),
    );
  }

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

  Widget bottomNavBar(BuildContext context) {
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
