import 'package:harlem/mysql.dart';
import 'package:flutter/material.dart';

class MySqlFlutter extends StatefulWidget {
  const MySqlFlutter({super.key});
  
  @override
  _MySqlFlutterState createState() => _MySqlFlutterState();
}

class _MySqlFlutterState extends State<MySqlFlutter> {

  final padding = EdgeInsets.all(15);

  var db = new Mysql();
  var assigned_id = '';
  var ltd = '';
  var lat = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MySQL Information',
        style: TextStyle(fontFamily: 'TrajanPro'),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 500,
          padding: padding,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 231, 215, 215),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'id: $assigned_id',
                  ),
                  Divider( color: Colors.black,),
                  Text(
                    'longitude: $ltd',
                  ),
                  Divider( color: Colors.black,),
                  Text(
                    'latitude: $lat',
                  )
                ],
              ),
            )
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCustomer,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

    void _getCustomer() {
    db.getConnection().then((conn) {
      String sql = 'select assigned_id, ltd, lat from harlem_employee.time where id = 12345678910;';
      conn.query(sql).then((results) {
        for(var row in results){
          setState(() {
            assigned_id = row[0];
            ltd = row[1];
            lat = row[2];
          });
        }
      });
      conn.close();
    });
  }
}
