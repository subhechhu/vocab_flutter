import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocab/services/IdomModel.dart';
import 'package:vocab/services/words.dart';

class DbHelper {
  Future<Database> _database;

  Future<Database> getDbInstance() async {
    if (_database == null) {
      _database = openDatabase(
        join(await getDatabasesPath(), 'vocab_database.db'),
        onCreate: (db, version) async {
          await db.execute(
              'CREATE TABLE words (correct INTEGER DEFAULT 0, incorrect INTEGER DEFAULT 0, word TEXT UNIQUE, pronunciation TEXT, meaning TEXT, sentence TEXT, time INTEGER DEFAULT 0)');
          await db.execute(
              'CREATE TABLE idoms (ID INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT UNIQUE, meaning TEXT, sentence TEXT, time INTEGER DEFAULT 0)');
        },
        version: 4,
      );
    }
    return _database;
  }

  Future<int> getTotalRows() async {
    final db = await _database;
    int count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words'));
    return count;
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

  Future<List<Words>> getAllWords(order) async {
    String orderText;

    if (order) {
      orderText = 'word';
    } else {
      orderText = 'word DESC';
    }
    final db = await _database;
    final List<Map<String, dynamic>> maps =
        await db.query('words', orderBy: '$orderText');
    return List.generate(maps.length, (i) {
      return Words(
          word: maps[i]['word'],
          pronunciation: maps[i]['pronunciation'],
          meaning: maps[i]['meaning'],
          sentence: maps[i]['sentence'],
          correct: maps[i]['correct'],
          incorrect: maps[i]['incorrect'],
          time: maps[i]['time']);
    });
  }

  Future<List<Words>> getRecentWords(int count, type) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps =
        await db.query('words', limit: count, orderBy: '$type');
    return List.generate(maps.length, (i) {
      return Words(
          word: maps[i]['word'],
          pronunciation: maps[i]['pronunciation'],
          meaning: maps[i]['meaning'],
          sentence: maps[i]['sentence'],
          correct: maps[i]['correct'],
          incorrect: maps[i]['incorrect'],
          time: maps[i]['time']);
    });
  }

  Future<int> updateWord(Words words) async {
    final db = await _database;
    int update = await db.update(
      'words',
      words.toMap(),
      where: 'word = ?',
      whereArgs: [words.word],
    );
    return update;
  }

  Future<int> deleteWord(word) async {
    final db = await _database;
    int delete = await db.delete(
      'words',
      where: 'word = ?',
      whereArgs: [word],
    );
    return delete;
  }

  Future<Words> getRandomData() async {
    final db = await _database;
    final List<Map<String, Object>> maps =
        await db.rawQuery('select * from words order by random() limit 1');
    if (maps.length > 0) {
      return Words(
          word: maps[0]['word'],
          pronunciation: maps[0]['pronunciation'],
          meaning: maps[0]['meaning'],
          sentence: maps[0]['sentence'],
          correct: maps[0]['correct'],
          incorrect: maps[0]['incorrect'],
          time: maps[0]['time']);
    }
    return null;
  }

  Future<int> insertIdom(IdomModel idoms) async {
    final db = await _database;
    print(db.isOpen);
    print(db.path);
    int insert = await db.insert(
      'idoms', //table
      idoms.toMap(), //data to insert
      conflictAlgorithm:
          ConflictAlgorithm.replace, // replace if Primary key reoccurs
    );
    print('insert data: $insert');
    return insert;
  }

  Future<List<IdomModel>> getAllIdoms(order) async {
    String q = '';
    if (order) {
      q = 'SELECT * FROM idoms ORDER BY RANDOM()';
    } else {
      q = 'SELECT * FROM idoms ORDER BY word';
    }
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('$q');
    return List.generate(maps.length, (i) {
      return IdomModel(
          word: maps[i]['word'],
          meaning: maps[i]['meaning'],
          sentence: maps[i]['sentence'],
          id: maps[i]['id'],
          time: maps[i]['time']);
    });
  }

  Future<int> updateIdom(IdomModel idoms) async {
    final db = await _database;
    int update = await db.update(
      'idoms',
      idoms.toMap(),
      where: 'id = ?',
      whereArgs: [idoms.id],
    );
    return update;
  }

  Future<int> deleteIdom(id) async {
    final db = await _database;
    int delete = await db.delete(
      'idoms',
      where: 'id = ?',
      whereArgs: [id],
    );
    return delete;
  }
}
