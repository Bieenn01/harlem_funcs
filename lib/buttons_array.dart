import 'package:harlem/qr_scanner.dart';
import 'package:flutter/material.dart';

class ArrayWidgetButtons extends StatefulWidget {
  const ArrayWidgetButtons({super.key});

  @override
  State<ArrayWidgetButtons> createState() => _ArrayWidgetButtonsState();
}

class _ArrayWidgetButtonsState extends State<ArrayWidgetButtons> {

  final padding = EdgeInsets.all(10);
  final centerPadding = EdgeInsets.all(25);

  final List<Map<String, String>> myButtons = [
  {
    'title': 'This is button the 1st button',
  },
  {
    'title': 'This is the 2nd button'
  },
  {
    'title': 'This is the 3rd button'
  },
  {
    'title': 'This is the 4th button'
  },
  {
    'title': 'This is the 5th button'
  }
  ];

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Buttons Array'),
        ),
        body: Center(
          child: Container(
            width: 300,
            margin: EdgeInsets.all(10),
            padding:  centerPadding,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              color: const Color.fromARGB(255, 201, 197, 197),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.menu_open),
                    ),
                    Text('<-- Press Here')
                  ]
                ),
                for(var item in myButtons) 
                  Container(
                    padding: padding,
                    decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(23)
                  ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigator.push(
                        //   context, MaterialPageRoute(builder: (context) => const WidgetQrScanner()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 196, 218, 235)
                      ), icon: Icon(Icons.camera_alt_rounded),
                      label: Text(item['title']!),
                    ),
                  ),
              ],
            ),
          )
        )
      )
    );
  }
}