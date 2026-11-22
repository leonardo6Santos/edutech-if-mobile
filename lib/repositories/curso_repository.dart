import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/curso.dart';

class CursoRepository {
  Future<int> inserir(Curso curso) async {
    final db = await DbHelper.instance.database;
    try {
      return await db.insert('cursos', curso.toMap());
    } on DatabaseException {
      throw Exception('Erro ao cadastrar o curso no banco de dados.');
    }
  }

  Future<List<Curso>> listar({
    required int usuarioId,
    int? categoriaId,
    String? busca,
  }) async {
    final db = await DbHelper.instance.database;

    final whereClauses = <String>['c.usuario_id = ?'];
    final whereArgs = <Object>[usuarioId];

    if (categoriaId != null) {
      whereClauses.add('c.categoria_id = ?');
      whereArgs.add(categoriaId);
    }

    if (busca != null && busca.trim().isNotEmpty) {
      whereClauses.add(
        '(LOWER(c.titulo) LIKE ? OR LOWER(c.instrutor) LIKE ? OR LOWER(c.descricao) LIKE ?)',
      );
      final termo = '%${busca.trim().toLowerCase()}%';
      whereArgs.addAll([termo, termo, termo]);
    }

    final rows = await db.rawQuery('''
      SELECT c.*, cat.nome AS categoria_nome
      FROM cursos c
      LEFT JOIN categorias cat ON cat.id = c.categoria_id
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY c.criado_em DESC
    ''', whereArgs);

    return rows.map(Curso.fromMap).toList();
  }

  Future<int> atualizar(Curso curso) async {
    if (curso.id == null) {
      throw Exception('Curso sem ID válido para atualização.');
    }

    final db = await DbHelper.instance.database;
    try {
      return await db.update(
        'cursos',
        curso.toMap(),
        where: 'id = ?',
        whereArgs: [curso.id],
      );
    } on DatabaseException {
      throw Exception('Erro ao atualizar o curso.');
    }
  }

  Future<int> excluir(int id) async {
    final db = await DbHelper.instance.database;
    try {
      return await db.delete(
        'cursos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException {
      throw Exception('Erro ao excluir o curso.');
    }
  }
}