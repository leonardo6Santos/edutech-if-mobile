import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'edutech_if.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        criado_em TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE,
        descricao TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cursos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        instrutor TEXT NOT NULL,
        carga_horaria INTEGER NOT NULL CHECK (carga_horaria > 0),
        nivel TEXT NOT NULL,
        url_material TEXT,
        categoria_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        criado_em TEXT NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE RESTRICT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    final categoriasIniciais = [
      {
        'nome': 'Desenvolvimento Mobile',
        'descricao': 'Flutter, Dart, Android e aplicações móveis',
      },
      {
        'nome': 'Web & Backend',
        'descricao': 'APIs, bancos de dados e desenvolvimento web',
      },
      {
        'nome': 'Redes e Infraestrutura',
        'descricao': 'Servidores, Linux, redes e segurança da informação',
      },
    ];

    for (final categoria in categoriasIniciais) {
      await db.insert('categorias', categoria);
    }
  }
}