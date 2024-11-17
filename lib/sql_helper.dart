import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  static Future<Database> getDatabaseConnection() async {

    var databaseFactory = databaseFactoryFfiWeb;
    String path = 'aula_web.db'; 

    return await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (Database banco, int version) async {
        await banco.execute(generate_tables());
      },
    ));
  }

  static String generate_tables() {
    return '''
                create table usuario(
                  idusuario integer primary key autoincrement,
                  nome text not null,
                  email text
                );
''';
  }

  static Future<int> gravar(String nome, String email, [int id = 0]) async {
    Database banco = await getDatabaseConnection();
    final values = {'nome': nome, 'email': email};
    if (id > 0) {
      return banco.update(
        'usuario',
        values,
        where: 'idusuario = ?',
        whereArgs: [id],
      );
    } else {
      return banco.insert('usuario', values);
    }
  }

  static Future<List<Map<String, Object?>>> listar(
      [String campoOrdem = 'nome']) async {
    Database banco = await getDatabaseConnection();
    return banco.query('usuario', orderBy: campoOrdem);
  }

  static Future<int> deletar(int id) async {
    Database banco = await getDatabaseConnection();
    return banco.delete(
      'usuario',
      where: 'idusuario = ?',
      whereArgs: [id],
    );
  }

  
}
