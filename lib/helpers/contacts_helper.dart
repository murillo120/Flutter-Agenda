import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String table = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String phoneColumn = "phoneColumn";
final String emailColumn = "emailColumn";
final String imgColumn = "imgColumn";

class Contacts_helper {
  
  static final Contacts_helper instance = Contacts_helper.internal();

  factory Contacts_helper() => instance;

  Contacts_helper.internal();

  Database _database;

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDatabase();

      return _database;
    }
  }

  //inicializa o banco de dados interno
  Future<Database> initDatabase() async {

    //pegar o caminho do banco de dados
    final databasepath = await getDatabasesPath();
    final path = join(databasepath, "databaseAgenda.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerversion) async {
      await db.execute(
          "CREATE TABLE $table($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;

    contact.id = await dbContact.insert(table, contact.toMap());

    return contact;
  }

  Future<Contact> getContact(int idContact) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(table,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [idContact]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;

    return await dbContact.delete(table, where: "$id = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;

    return await dbContact.update(table, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;

    List listmap = await dbContact.rawQuery("SELECT * FROM $table");

    List<Contact> contacts = List();

    for (Map m in listmap) {
      contacts.add(Contact.fromMap(m));
    }

    return contacts;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;

    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) $table"));
  }

  Future closeDB() async {
    Database dbContact = await db;

    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String phone;
  String email;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    //Construtor
    id = map[idColumn];
    name = map[nameColumn];
    phone = map[phoneColumn];
    email = map[emailColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contato:  -  id:$id name:$name phone:$phone email:$email img:$img ";
  }
}
