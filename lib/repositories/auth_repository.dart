import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/usuario.dart';

class AuthRepository {
  static const _salt = 'EduTechIF_IFSULDEMINAS_Salt_2026';

  String _gerarHash(String senha, String emailNormalizado) {
    final payload = '$_salt:$emailNormalizado:$senha';
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }

  Future<Usuario> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await DbHelper.instance.database;
    final emailLimpo = email.trim().toLowerCase();
    final criadoEm = DateTime.now().toIso8601String();
    final senhaHash = _gerarHash(senha, emailLimpo);

    final usuario = Usuario(
      nome: nome.trim(),
      email: emailLimpo,
      senhaHash: senhaHash,
      criadoEm: criadoEm,
    );

    try {
      final id = await db.insert('usuarios', usuario.toMap());
      return Usuario(
        id: id,
        nome: usuario.nome,
        email: usuario.email,
        senhaHash: usuario.senhaHash,
        criadoEm: usuario.criadoEm,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Já existe um usuário cadastrado com este e-mail.');
      }
      throw Exception('Erro ao cadastrar usuário no banco de dados.');
    }
  }

  Future<Usuario?> login({
    required String email,
    required String senha,
  }) async {
    final db = await DbHelper.instance.database;
    final emailLimpo = email.trim().toLowerCase();
    final senhaHash = _gerarHash(senha, emailLimpo);

    final rows = await db.query(
      'usuarios',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [emailLimpo, senhaHash],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Usuario.fromMap(rows.first);
  }
}