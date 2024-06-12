import 'package:flutter/material.dart';
import 'package:jokerly/models/deck_model.dart';
import 'package:jokerly/widgets/flashcard_widget.dart';

class DeckPage extends StatefulWidget {
  final FlashcardDeck deck;

  const DeckPage({super.key, required this.deck});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: deckAppBar(context),
      body: Container(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            _edit ? editMenu(context) : const SizedBox(),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                clipBehavior: Clip.none,
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
            ),
          ],
        ),
      ),
    );
  }

  AppBar deckAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: widget.deck.color,
      foregroundColor: Colors.white,
      toolbarHeight: 50,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 10,
            stops: const [0.0, 1.0],
            colors: [
              widget.deck.color,
              Color.alphaBlend(widget.deck.color.withAlpha(180), Colors.white),
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
            onPressed: () => setState(() {
              _edit = !_edit;
            }),
            tooltip: "Edit",
          ),
        ),
      ],
    );
  }

  Container editMenu(BuildContext context) {
    TextEditingController descController =
        TextEditingController(text: widget.deck.description);
    double hue = HSLColor.fromColor(widget.deck.color).hue;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.5,
          stops: const [0.0, 1.0],
          colors: [
            widget.deck.color,
            Color.alphaBlend(widget.deck.color.withAlpha(180), Colors.white),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              hintText: "A description for the content of this deck",
            ),
            onSubmitted: (String newValue) => setState(() {
              widget.deck.description = newValue;
            }),
          ),
          Slider(
            value: hue,
            min: 0.0,
            max: 330.0,
            divisions: 12,
            label: "Color",
            activeColor: const Color(0xff2a2a2a),
            onChanged: (double newValue) => setState(
              () {
                widget.deck.color =
                    HSLColor.fromAHSL(1.0, newValue, 0.5, 0.6).toColor();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => print("delete"),
                icon: Icon(Icons.delete_forever),
                tooltip: "Delete",
              )
            ],
          ),
        ],
      ),
    );
  }
}
