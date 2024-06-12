import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '10.0.0.11',
                user = 'root',
                password = 'alpha',
                db = 'harlem_employee';
  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db:db
    );
    return await MySqlConnection.connect(settings);
  }
}