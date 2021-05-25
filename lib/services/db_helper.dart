import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocab/services/words.dart';

class DbHelper {
  Future<Database> _database;

  Future<Database> getDbInstance() async {
    if (_database == null) {
      _database = openDatabase(
        join(await getDatabasesPath(), 'vocab_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, correct INTEGER DEFAULT 0, incorrect INTEGER DEFAULT 0, word TEXT UNIQUE, pronunciation TEXT, meaning TEXT, sentence TEXT)',
          );
        },
        version: 1,
      );
    }
    return _database;
  }

  Future<int> insertWord(Words words) async {
    final db = await _database;
    int insert = await db.insert(
      'words', //table
      words.toMap(), //data to insert
      conflictAlgorithm:
          ConflictAlgorithm.replace, // replace if Primary key reoccurs
    );
    print('insert data: $insert');
    return insert;
  }

  Future<List<Words>> getAllWords() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps =
        await db.query('words', orderBy: 'word');
    return List.generate(maps.length, (i) {
      return Words(
        id: maps[i]['id'],
        word: maps[i]['word'],
        pronunciation: maps[i]['pronunciation'],
        meaning: maps[i]['meaning'],
        sentence: maps[i]['sentence'],
        correct: maps[i]['correct'],
        incorrect: maps[i]['incorrect'],
      );
    });
  }

  Future<List<Words>> getRecentWords(int count) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps =
        await db.query('words', limit: count, orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Words(
        id: maps[i]['id'],
        word: maps[i]['word'],
        pronunciation: maps[i]['pronunciation'],
        meaning: maps[i]['meaning'],
        sentence: maps[i]['sentence'],
        correct: maps[i]['correct'],
        incorrect: maps[i]['incorrect'],
      );
    });
  }

  Future<int> updateWord(Words words) async {
    final db = await _database;
    int update = await db.update(
      'words',
      words.toMap(),
      where: 'id = ?',
      whereArgs: [words.id],
    );
    return update;
  }

  Future<int> deleteWord(int id) async {
    final db = await _database;
    int delete = await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
    return delete;
  }

  Future<Words> getRandomData() async {
    final db = await _database;
    final List<Map<String, Object>> maps =
        await db.rawQuery('select * from words order by random() limit 1');
    if (maps.length > 0) {
      return Words(
        id: maps[0]['id'],
        word: maps[0]['word'],
        pronunciation: maps[0]['pronunciation'],
        meaning: maps[0]['meaning'],
        sentence: maps[0]['sentence'],
        correct: maps[0]['correct'],
        incorrect: maps[0]['incorrect'],
      );
    }
    return null;
  }
}
