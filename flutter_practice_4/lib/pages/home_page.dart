import 'package:flutter/material.dart';
import 'package:flutter_practice_4/components/item_node.dart';
import 'add_item_page.dart';
import 'package:flutter_practice_4/models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.favoriteNotes, required this.addToFavorites});

  final List<Knopa> favoriteNotes; // Список избранных заметок
  final Function(Knopa) addToFavorites; // Функция добавления в избранное


  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
final List<Knopa> notes = <Knopa>[
  Knopa(
    id: 1,
    photoLink: 'assets/f1knopa.jpg',
    title: 'Кнопа F1',
    knopaDescription: 'Огурчики кнопа F1 нравятся всем!',
    innerKnopaDescription: 'Семена Огурец Кнопа F1 7шт по 2 упаковки. Раннеспелый самоопыляемый гибрид для любителей аккуратных корнишонов длиной не более 10 см. От всходов до сбора первых плодов 40-42 дня. Растение среднеплетистое, обладает высокой букетностью завязи. В узле формируется до 5 изящных изумрудных огурчиков. Зеленцы цилиндрические, частобугорчатые, с отличным вкусом, нежесткой кожурой и прекрасными засолочными качествами. Не имеют горечи, аппетитно хрустят в свежем и консервированном виде. Нравятся взрослым и детям.!',
    price: '1000 ₽',
    ),
    Knopa(id: 2,
    photoLink: 'assets/f1shem.jpg',
    title: 'Шремянин F1',
    knopaDescription: 'Огурчики Шремянин F1 нравятся почти всем!',
    innerKnopaDescription: 'Огурец Шремянин F1 высокопродуктивный сорт, относится к самым ранним сортам. Развивается преимущественно женские цветения. Высокая устойчивость к болезням, включая паршу огурца, мучнистую росу и мучнистую росу, является одним из самых больших преимуществ этого растения. Эти особенности обуславливают высокую урожайность «Сремианина F1» и высокое качество его посевов. Плоды приобретают правильную форму и покрыты бледно-зеленой блестящей кожурой с более светлыми полосками. Большое количество крошечных бородавок разбрызгивается на его поверхности. Плоды не желтеют, что делает их идеальными для маринования и маринования. ',
    price: '750 ₽',
    ),
    Knopa(
    id: 3,
    photoLink: 'assets/f1zhur.jpg',
    title: 'Журавлёнок F1',
    knopaDescription: 'Огурчики Журавлёнок F1 почти никому не нравятся.',
    innerKnopaDescription: 'Среднеранний, пчелоопыляемый гибрид. Выращивается в открытом грунте, а также под пленочными укрытиями. Растение среднерослое, главный стебель достигает в длину 150 — 190 см, дает до 3 – 5 боковых побегов.Плоды достигают длины 8-12 см, масса колеблется от 75 до 90 г. В одном узле формируется 4 – 5 плодов. Преимуществом данного сорта является тонкая кожура, зеленая, с белыми размытыми полосками, доходящими до середины плода, очень нежная и хрустящая мякоть. Форма плодов овально-цилиндрическая. Поверхность матовая, крупнобугорчатая, шипы черные. Длина плода 10-12 см, масса 75-90 г. Вкус хороший, без горечи. Растение не болеет наиболее опасной болезнью огурцов – мучнистой росой. Урожайность хорошая – более 10 кг на м. кв. Посев на рассаду в конце апреля. Высадка в грунт в конце мая - начале июня в фазе двух-трех настоящих листьев. Посев в открытый грунт проводится в конце мая - начале июня. Схема посадки 40x40 см. Приступить к посадке можно тогда, когда почва прогреется до +16…+18 оС.',
    price: '500 ₽',
    ),
    Knopa(
    id: 4,
    photoLink: 'assets/VERSTAPPEN.png',
    title: 'Ферстаппен F1',
    knopaDescription: 'Спелый огурчик Ферстаппен F1 никому не нравится.',
    innerKnopaDescription: 'Ранний, гибрид. Растение среднерослое. Выращено в теплице огородником Йосом. Нуждается в DRS (демисезонной релаксации). Хранится при температуре +60 и достигает скорости в 350 км/ч. Если увидите на улице, пожалуйста, верните его в теплицу.',
    price: '0 ₽',
    ),
  ];

  void addNewItem(Knopa newKnopa) {
    setState(() {
      notes.add(newKnopa);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Разные огурчики F1')),
      ),
    body: ListView.builder(
      itemCount: notes.length,
       itemBuilder: (BuildContext context, int index) {
      return ItemNode(knops: notes[index], favoriteToggle: widget.addToFavorites,
            isFavorite: widget.favoriteNotes.contains(notes[index]));
    }
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemPage(onItemAdded: addNewItem)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}