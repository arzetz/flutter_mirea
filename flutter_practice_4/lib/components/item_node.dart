import 'package:flutter/material.dart';
import 'package:flutter_practice_4/models/note.dart';
import 'package:flutter_practice_4/pages/note_page.dart';

// ignore: must_be_immutable
class ItemNode extends StatefulWidget {
  ItemNode({
    super.key,
    required this.knops,
    required this.favoriteToggle,
    required this.isFavorite,
  });

  final Knopa knops;
  final Function(Knopa) favoriteToggle;
  bool isFavorite;


 @override
  _ItemNodeState createState() => _ItemNodeState();
}

class _ItemNodeState extends State<ItemNode> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotePage(note: widget.knops),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color.fromARGB(255, 94, 94, 94),
              width: 3.0,
            ),
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      widget.knops.title,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Color.fromARGB(255, 48, 48, 48),
                      ),
                    ),
                  ),
                  Image(
                    image: AssetImage(widget.knops.photoLink),
                    height: 500,
                  ),
                  Center(
                    child: Text(
                      widget.knops.knopaDescription,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Стоит всего ${widget.knops.price}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 59, 59, 59),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: widget.isFavorite
                        ? Colors.red
                        : const Color.fromARGB(255, 198, 187, 186),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.isFavorite = !widget.isFavorite;
                    });
                    widget.favoriteToggle(widget.knops);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.isFavorite
                            ? 'Вы добавили в избранное ${widget.knops.title}'
                            : 'Вы убрали из избранного ${widget.knops.title}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}