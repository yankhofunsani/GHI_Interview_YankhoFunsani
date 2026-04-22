import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/repositorylist.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  // here am creting  a  local database called repos.db and a table called repository
  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'repos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE repository(
            id INTEGER PRIMARY KEY,
            name TEXT,
            isPrivate INTEGER,
            ownerName TEXT,
            ownerAvatar TEXT,
            repoUrl TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertRepo(Repository repo) async {
    final db = await database;

    await db.insert(
      'repository',
      {
        'id': repo.id,
        'name': repo.name,
        'isPrivate': repo.isPrivate ? 1 : 0,
        'ownerName': repo.ownerName,
        'ownerAvatar': repo.ownerAvatar,
        'repoUrl': repo.repoUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRepos(List<Repository> repos) async {
    for (var repo in repos) {
      await insertRepo(repo);
    }
  }

  Future<List<Repository>> getRepos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('repository');

    return maps.map((map) {
      return Repository(
        id: map['id'],
        name: map['name'],
        isPrivate: map['isPrivate'] == 1,
        ownerName: map['ownerName'],
        ownerAvatar: map['ownerAvatar'],
        repoUrl: map['repoUrl'],
      );
    }).toList();
  }
}