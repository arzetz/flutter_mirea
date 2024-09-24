import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/note.dart';
import 'package:flutter_application_1/pages/note_page.dart';

class ItemNode extends StatelessWidget {
  const ItemNode({super.key, required this.knops});

  final Knopa knops;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.push(context,
                     MaterialPageRoute(builder: (context) => NotePage(note: knops),
                     ),
                     ),
          child: Container(
            decoration: BoxDecoration(color:  const Color.fromARGB(255, 255, 255, 255), 
            borderRadius: BorderRadius.circular(16.0),
             border: Border.all(                             
      color: const Color.fromARGB(255, 94, 94, 94),                            
      width: 3.0,                                 
    ),
    ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                    knops.title,
                    style: const TextStyle(fontSize: 36, color: Color.fromARGB(255, 48, 48, 48)),
                  ),
                ),
                Image(
                  image: AssetImage(knops.photoLink),
                  height: 500,
                ),
                Center(
                 
                  child: Text(knops.knopaDescription,
                   style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                   fontSize: 20),
                   )
                   ),
                   const SizedBox(height: 20,),
                    Text('Стоит всего ${knops.price}', style: const TextStyle(color: Color.fromARGB(255, 59, 59, 59), fontSize: 18),),
              ], 
            ),
          ),
        ),
      );
  }
}