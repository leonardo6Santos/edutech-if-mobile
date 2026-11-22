import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
// import '../database/database_helper.dart'; // ajuste o caminho do seu DatabaseHelper

class CategoriaRepository {
  static const String tableName = 'categorias';

  // Ajuste conforme o seu DatabaseHelper
  Future<Database> get _db async {
    throw UnimplementedError(
      'Conecte aqui ao seu DatabaseHelper (ex.: return await DatabaseHelper.instance.database;)',
    );
  }

  Future<int> inserir(Categoria categoria) async {
    final db = await _db;
    return await db.insert(
      tableName,
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Categoria>> listarTodas() async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      orderBy: 'nome ASC',
    );
    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<Categoria?> buscarPorId(int id) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Categoria.fromMap(maps.first);
  }

  Future<int> atualizar(Categoria categoria) async {
    if (categoria.id == null) {
      throw ArgumentError('Não é possível atualizar categoria sem ID.');
    }
    final db = await _db;
    return await db.update(
      tableName,
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await _db;
    try {
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      final msg = e.toString().toUpperCase();
      if (msg.contains('FOREIGN KEY') || msg.contains('CONSTRAINT')) {
        throw Exception(
          'Não é possível excluir esta categoria porque existem cursos vinculados a ela.',
        );
      }
      rethrow;
    }
  }
}